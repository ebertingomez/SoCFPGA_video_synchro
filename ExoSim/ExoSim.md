# Simulation Évenementielle
**Élève: Enrique GOMEZ**

---

## Système à Simuler

<div align="center">

![alt text](exo_design.png "Schéma du Système")

</div>

## Données du Programme Initiales

- 50MHz de fréquence d’horloge
- 15ns de temps de propagation.

| P1                                 | P2                            | P3                     |
| ---------------------------------- | ----------------------------- | ---------------------- |
| H <= 0;<br>#10;<br>H <= 1;<br>#10; | @(H);<br>if H ==1<br> Q <= D; | @(Q);<br>D <= #15 Q+1; |

## Simulation

Conditions Intiales :

- H=0
- D=1

| Temps Symbolique | Temps Physique | Processus   | D                      | H                       | Q                      |
| ---------------- | -------------- | ----------- | ---------------------- | ----------------------- | ---------------------- |
| Init             | 0ns            |             | (x,x)                  | (x,x)                   | (x,x)                  |
| $$\Delta_{0}$$   | 0ns            | P0<br>m.a.j | (x,**1**)<br>(**1**,1) | (x,**0**)<br>(**0**,0)  | (x,x)<br>(x,x)         |
| $$\Delta_{1}$$   | 0ns            | P1<br>m.a.j | -<br>(1,1)             | (0,**0**) <br>(**0**,0) | -<br>(x,x)             |
| $$\Delta_{2}$$   | 10ns           | P1<br>m.a.j | -<br>(1,1)             | (0,**1**) <br>(**1**,1) | -<br>(x,x)             |
| $$\Delta_{3}$$   | 10ns           | P2<br>m.a.j | -<br>(1,1)             | - <br>(1,1)             | (x,**1**)<br>(**1**,1) |
| $$\Delta_{4}$$   | 20ns           | P1<br>m.a.j | -<br>(1,1)             | (1,**0**) <br>(**0**,0) | -<br>(1,1)             |
| $$\Delta_{5}$$   | 25ns           | P3<br>m.a.j | (1,**2**)<br>(**2**,2) | -<br>(0,0)              | -<br>(1,1)             |
| $$\Delta_{6}$$   | 30ns           | P1<br>m.a.j | -<br>(2,2)             | (0,**1**) <br>(**1**,1) | -<br>(1,1)             |
| $$\Delta_{7}$$   | 30ns           | P2<br>m.a.j | -<br>(2,2)             | - <br>(1,1)             | (1,**2**)<br>(**2**,2) |
| $$\Delta_{8}$$   | 40ns           | P1<br>m.a.j | -<br>(2,2)             | (1,**0**) <br>(**0**,0) | -<br>(2,2)             |
| $$\Delta_{9}$$   | 45ns           | P3<br>m.a.j | (2,**3**)<br>(**3**,3) | -<br>(0,0)              | -<br>(2,2)             |