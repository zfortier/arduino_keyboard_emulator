#!/usr/local/bin/python3
from collections import deque

def LCS(string):
    l = list(string)
    d = deque(string[1:])
    match = []
    longest_match = []
    while d:
        for i, item in enumerate(d):
            if l[i]==item:
                match.append(item)
            else:
                if len(longest_match) < len(match):
                    longest_match = match
                match = []
        d.popleft()
    return ''.join(longest_match)


f1=open("/Users/z050789/Desktop/cap.txt", "r")
s1=f1.read()
f1.close()

print(LCS(s1))


