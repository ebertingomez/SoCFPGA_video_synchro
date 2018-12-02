# Simulation Évenementielle

---

![alt text](exo_design.png "Schéma du Système")

## Conditions Initiales

- 50MHz de fréquence d’horloge
- 15ns de temps de propagation.

| P1                                 | P2                            | P3                     |
| ---------------------------------- | ----------------------------- | ---------------------- |
| H <= 0;<br>#10;<br>H <= 1;<br>#10; | @(H);<br>if H ==1<br> Q <= D; | @(Q);<br>D <= #15 Q+1; |

## Simulation du Parallélisme

| Temps Symbolique | Temps Physique | Processus             | D   | H   | Q   |
| ---------------- | -------------- | --------------------- | --- | --- | --- |
| $\Delta$         |                | P1<br>P2<br>P3<br>Fin |     |     |     |
|                  |                |                       |     |     |     |
