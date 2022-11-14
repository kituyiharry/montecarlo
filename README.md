
### Usage

run `dune build` to generate the binary in the build directory. then use the
`NDOMS` environment variable to vary the _domains_ used.


### Sample results

```
num_domains: 8
Single Thread

Exec: 0.000003 seconds  Size: 5         Res: 2.678281
Exec: 0.000003 seconds  Size: 14        Res: 2.725442
Exec: 0.000493 seconds  Size: 858       Res: 3.087410
Exec: 0.001714 seconds  Size: 9106      Res: 3.057147
Exec: 0.003877 seconds  Size: 18136     Res: 3.077361
Exec: 0.071755 seconds  Size: 665028    Res: 3.061506
Exec: 0.067526 seconds  Size: 993453    Res: 3.059585
Exec: 9.577461 seconds  Size: 91052150  Res: 3.060980

Multi Thread SCAN

Exec: 0.000539 seconds  Size: 8         Res: 3.047450
Exec: 0.000037 seconds  Size: 54        Res: 2.989366
Exec: 0.000747 seconds  Size: 586       Res: 3.041657
Exec: 0.000017 seconds  Size: 19        Res: 2.818819
Exec: 0.005221 seconds  Size: 41438     Res: 3.052345
Exec: 0.028091 seconds  Size: 297685    Res: 3.061072
Exec: 1.057608 seconds  Size: 8079133   Res: 3.060771
Exec: 8.929499 seconds  Size: 66326681  Res: 3.060704

Multi Thread REDUCE   - (scales the best IMO)

Exec: 0.001374 seconds  Size: 6         Res: 3.130307
Exec: 0.000054 seconds  Size: 23        Res: 2.661898
Exec: 0.001265 seconds  Size: 55        Res: 3.046688
Exec: 0.000760 seconds  Size: 6336      Res: 3.058560
Exec: 0.002373 seconds  Size: 12472     Res: 3.040393
Exec: 0.043060 seconds  Size: 594086    Res: 3.061167
Exec: 0.558913 seconds  Size: 9202443   Res: 3.060591
Exec: 4.561357 seconds  Size: 62377177  Res: 3.060660

Multi Thread JOINSCAN

Exec: 0.000001 seconds  Size: 2         Res: 1.330122
Exec: 0.000016 seconds  Size: 19        Res: 0.024427
Exec: 0.000079 seconds  Size: 477       Res: 0.005504
Exec: 0.001763 seconds  Size: 1480      Res: 0.001321
Exec: 0.002136 seconds  Size: 19803     Res: 0.000150
Exec: 0.030102 seconds  Size: 382109    Res: 0.000006
Exec: 0.281898 seconds  Size: 3250097   Res: 0.000000
Exec: 21.683137 seconds Size: 58988694  Res: 0.000000
```
