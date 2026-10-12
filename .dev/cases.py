def kill(cast, start, n=4):      # hit the nearest monster of that cast n times, 25 ticks apart
    return ";".join("%d:near=%d;%d:atk" % (t, cast, t + 1) for t in range(start, start + 25 * n, 25))


LP = "[lua:4rtefakt.bestiary] "
CASES = {
    # A first kill makes the entry (the game's own name for cast 17, level 3) and announces it; a kill of
    # another kind (cast 43, level 4) adds a second entry; the log comes back from a save and load.
    "log": dict(room="S_10/S_1002/S_1002",
        drive="8:opt=DamageDealt=10;10:opt=DamageTaken=0;" + kill(17, 40) + ";150:lua=best;" + kill(43, 160, 9) + ";400:lua=best;"
              "410:saveload;450:lua=best;460:quit",
        expect=["notice New in the bestiary: Selnarg (level 3)", LP + "new kind: Selnarg level 3 in S_1002",
                LP + "Selnarg lv 3: 1 killed  -  51 EXP  -  4 SP, first met in S_1002", LP + "1 kinds",
                LP + "new kind: Baocar level 4 in S_1002", LP + "Baocar lv 4: 1 killed  -  ", LP + "2 kinds",
                LP + "Selnarg lv 3: 1 killed  -  51 EXP  -  4 SP, first met in S_1002", LP + "Baocar lv 4: 1 killed  -  ", LP + "2 kinds"]),
}
