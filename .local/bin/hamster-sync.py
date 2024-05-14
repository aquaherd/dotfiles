#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sqlite3 as lite
import sys

print(sys.argv[1:])

n = 0


def cb():
    global n
    n += 72
    return None


src = lite.connect(sys.argv[1])

cur = src.cursor()
cur.execute("attach database '" + sys.argv[2] + "' as dst")
src.set_progress_handler(cb, 72)
cur.execute('''
            select
                facts.id as id,
                activities.name as act,
                activity_id,
                start_time as st,
                end_time as et,
                description,
                tags.name as tag,
                tag_id
            from facts
                inner join activities on activities.id = facts.activity_id
                left outer join fact_tags on fact_tags.fact_id = facts.id
                left outer join tags on tags.id = fact_tags.tag_id
            where
            not exists (
                select
                    1 from dst.facts
                where
                    strftime('%Y-%m-%d %H:%M', dst.facts.start_time) =
                    strftime('%Y-%m-%d %H:%M', st)
            )
            and
                end_time is not null
            order by st desc
            ''')

col_names = [cn[0] for cn in cur.description]

rows = cur.fetchall()

print(col_names)

print("rows=", len(rows))
for row in rows:
    print(row[2], row[3], row[4], row[5], )
    cur.execute("insert into dst.facts values (null, ?, ?, ?, ?)",
                (row[2], row[3], row[4], row[5]))
    last = cur.lastrowid
    print("=", last, )
    if row[7] is None:
        print("no tag")
    else:
        cur.execute("insert into dst.fact_tags values(?, ?)", (last, row[7]))
        print("tagged=", row[6])
print(cur.lastrowid, len(rows), n)
src.commit()
cur.close()
