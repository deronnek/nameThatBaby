from __future__ import print_function
import sqlite3
import trueskill
import argparse
import random
import string
import itertools
from itertools import combinations
from operator import itemgetter
from math import floor, log
from scipy.stats import ttest_ind_from_stats

def bhatta(m1, s1, m2, s2):
    # Calculate the Bhattacharyya distance between two normal distibutions,
    # defined by their means (m#) and standard deviations (s#)

    # Convert s.d. to variance (sigma^2)
    v1 = s1**2
    v2 = s2**2

    first = (v1 / v2) + (v2 / v1)
    second = ((m1 - m2)**2) / (v1 + v2)

    return (0.25 * log(0.25 * (first + 2))) + (0.25 * second)


def present(name1, name2):
    print()
    print("a) {} Owen".format(name1))
    print("  or")
    print("b) {} Owen".format(name2))


def get_input():
    return raw_input("  ? ")[0]


def initialize(f):
    for line in f:
        add_name(line.strip())


def get_last_round():
    cur = con.cursor()
    cur.execute("SELECT max(round) FROM data")
    return cur.fetchone()[0]


def add_name(name):
    #print("Adding name: {}".format(name))
    cur = con.cursor()
    cur.execute("INSERT INTO names (name, rounds) VALUES (?,?)", (name, 0))
    cur.execute("INSERT INTO data VALUES (?,?,?,?)", (0, cur.lastrowid, trueskill.MU, trueskill.SIGMA))


def get_ids():
    cur = con.cursor()
    cur.execute("SELECT id FROM names")
    return [r[0] for r in cur.fetchall()]


def get_name_id(name):
    cur = con.cursor()
    cur.execute("SELECT id FROM names WHERE name = ?", (name,))
    return cur.fetchone()[0]


def get_id_name(id):
    cur = con.cursor()
    cur.execute("SELECT name FROM names WHERE id = ?", (id,))
    return cur.fetchone()[0]


def get_name_stats(name):
    return get_id_stats(get_name_id(name))


def get_id_stats(id):
    cur = con.cursor()
    cur.execute("SELECT mu, sigma, round FROM data WHERE id = ? ORDER BY round DESC LIMIT 1", (id,))
    return cur.fetchone()


def get_results():
    ids = get_ids()
    results = []
    for id in ids:
        name = get_id_name(id)
        mu, sigma, round = get_id_stats(id)
        results.append({'id': id, 'name': name, 'mu': mu, 'sigma': sigma, 'cov': sigma / mu, 'round':round})

    return results


def update_name_stats(id, mu, sigma, round):
    cur = con.cursor()
    cur.execute("INSERT INTO data VALUES (?,?,?,?)", (round, id, mu, sigma))
    cur.execute("UPDATE names SET rounds = rounds + 1 WHERE id = ?", (id,))


def pick_pair_nrounds():
    cur = con.cursor()
    # pick the two names which have gone through the fewest rounds
    cur.execute("SELECT id FROM names ORDER BY rounds ASC, RANDOM() LIMIT 2")
    return [r[0] for r in cur.fetchall()]


def pick_pair_cov_high():
    cur = con.cursor()
    # pick the two names which have the highest COV (sigma/mu, theoretically the most uncertainty remaining)
    cur.execute("SELECT id FROM data ORDER BY sigma/mu DESC, RANDOM() LIMIT 2")
    return [r[0] for r in cur.fetchall()]


def pick_pair_cov_mix():
    cur = con.cursor()
    pair = []

    # pick the name which has the highest COV and the name which has the lowest COV
    cur.execute("SELECT id FROM data ORDER BY sigma/mu DESC, RANDOM() LIMIT 1")
    pair.extend([r[0] for r in cur.fetchall()])

    cur.execute("SELECT id FROM data ORDER BY sigma/mu ASC, RANDOM() LIMIT 1")
    pair.extend([r[0] for r in cur.fetchall()])

    return pair


def pick_pair_cov_median_split():
    r = sorted(get_results(), key=itemgetter('cov'))

    # pick one from the top 50% by cov, the other from the bottom 50%
    h = int(floor(len(r) / 2))
    tophalf = [x['id'] for x in r[:h]]
    bottomhalf = [x['id'] for x in r[h:]]

    return [random.choice(tophalf), random.choice(bottomhalf)]


def pick_pair_minimum_z():
    results = get_results()

    # pick the pair whose distributions indicate the greatest probability that they have the same value
    # will this always pick pairs in adjacent ranks?
    pair = [None, None]
    max_p = 0
    for c1, c2 in combinations(results, 2):
            t, p = ttest_ind_from_stats(c1['mu'], c1['sigma'], max(c1['round'], 2),
                                        c2['mu'], c2['sigma'], max(c2['round'], 2), False)
            if p > max_p:
                pair = [c1['id'], c2['id']]
                max_p = p

    print("Max p: {:.4f}".format(max_p))
    return max_p, pair[0], pair[1]


def play_round(matcher):
    this_round = get_last_round() + 1
    p, id1, id2 = matcher()
    m1, s1, r1 = get_id_stats(id1)
    m2, s2, r2 = get_id_stats(id2)
    r1 = TS.create_rating(m1, s1)
    r2 = TS.create_rating(m2, s2)

    if id1 < id2:
        new_r1, new_r2 = trueskill.rate_1vs1(r1, r2, env=TS)
    else:
        new_r2, new_r1 = trueskill.rate_1vs1(r2, r1, env=TS)

    update_name_stats(id1, new_r1.mu, new_r1.sigma, this_round)
    update_name_stats(id2, new_r2.mu, new_r2.sigma, this_round)
    return True


def print_results():
    results = get_results()

    i = 1
    for result in sorted(results, key=itemgetter('mu'), reverse=True):
        print("{}) {}\t\t({:.4g}, {:.4g})".format(i, result['name'], result['mu'], result['sigma']))
        i = i + 1


def is_sorted():
    results = get_results()

    true = sorted(results, key=itemgetter('id'))
    current = sorted(results, key=itemgetter('mu'), reverse=True)

    show_sort_state(true, current)

    #if true == current:
    #    return True

    #return False

    p, x, y = pick_pair_minimum_z()
    if p < 0.05:
        return True

    return False

def show_sort_state(true, current):
    for n in range(len(true)):
        print("{}:  {}  {} {:.3f}".format(n, true[n]['id'], current[n]['id'], current[n]['cov']))

    print("")


def init_db(schema_file='schema.sql'):
    with open(schema_file) as f:
        script = f.read()
        cur = con.cursor()
        cur.executescript(script)


def make_names(n):
    for i in range(n):
        name = ''.join([random.choice(string.lowercase) for i in xrange(10)])
        add_name(name)


matchers = {"min-rounds": pick_pair_nrounds,
            "cov-high": pick_pair_cov_high,
            "cov-bookends": pick_pair_cov_mix,
            "cov-median": pick_pair_cov_median_split,
            "min-z": pick_pair_minimum_z}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', type=int, required=True)
    parser.add_argument('-m', '--matcher', type=str, required=False, default="min-rounds")
    args = parser.parse_args()

    matcher = matchers[args.matcher]

    con = sqlite3.connect(':memory:')
    con.isolation_level = None
    TS = trueskill.TrueSkill(draw_probability=0.0)

    init_db()

    make_names(args.n)

    n_rounds = 0
    while not is_sorted():
        play_round(matcher)
        print("Played round {}".format(n_rounds))
        n_rounds += 1

    print("Sorted after {} rounds".format(n_rounds))
