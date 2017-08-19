from __future__ import print_function
import sqlite3
import trueskill
import argparse
from operator import itemgetter


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
    print("Adding name: {}".format(name))
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
    cur.execute("SELECT mu, sigma FROM data WHERE id = ? ORDER BY round DESC LIMIT 1", (id,))
    return cur.fetchone()


def update_name_stats(id, mu, sigma, round):
    cur = con.cursor()
    cur.execute("INSERT INTO data VALUES (?,?,?,?)", (round, id, mu, sigma))
    cur.execute("UPDATE names SET rounds = rounds + 1 WHERE id = ?", (id,))


def pick_pair():
    cur = con.cursor()
    cur.execute("SELECT id FROM names ORDER BY rounds ASC, RANDOM() LIMIT 2")
    return [r[0] for r in cur.fetchall()]


def play_round():
    this_round = get_last_round() + 1
    id1, id2 = pick_pair()
    name1 = get_id_name(id1)
    name2 = get_id_name(id2)
    m1, s1 = get_id_stats(id1)
    m2, s2 = get_id_stats(id2)
    r1 = TS.create_rating(m1, s1)
    r2 = TS.create_rating(m2, s2)

    present(name1, name2)
    response = get_input()
    if response == 'a':
        new_r1, new_r2 = trueskill.rate_1vs1(r1, r2, env=TS)
    elif response == 'b':
        new_r2, new_r1 = trueskill.rate_1vs1(r2, r1, env=TS)
    elif response == 'q':
        return False
    else:
        print("Invalid key pressed: {}".format(response))
        return True

    update_name_stats(id1, new_r1.mu, new_r1.sigma, this_round)
    update_name_stats(id2, new_r2.mu, new_r2.sigma, this_round)
    return True


def print_results():
    ids = get_ids()
    results = []
    for id in ids:
        name = get_id_name(id)
        mu, sigma = get_id_stats(id)
        results.append({'name':name, 'mu':mu, 'sigma':sigma})

    i = 1
    for result in sorted(results, key=itemgetter('mu'), reverse=True):
        print("{}) {}\t\t({:.4g}, {:.4g})".format(i, result['name'], result['mu'], result['sigma']))
        i = i + 1


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--init', type=file, required=False, default=None)
    parser.add_argument('--results', action='store_true')
    parser.add_argument('db')
    args = parser.parse_args()

    con = sqlite3.connect(args.db)
    con.isolation_level = None
    TS = trueskill.TrueSkill(draw_probability=0.0)

    if args.init:
        for line in args.init:
            add_name(line.strip())

    if args.results:
        print_results()
    else:
        repeat = True
        while repeat:
            repeat = play_round()
