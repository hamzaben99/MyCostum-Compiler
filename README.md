## Projet de compilation

Ce projet vise la realisation d'un compilateur d'un mini langage appelé  myC vers du codeC à 3 adresses.  
Notre compilateur (comme gcc ) nécessite une fonction main qui va être comme point de début d’exécution(sinon un code c sera généré sans possibilité d’être exécuter ).

 
*Les objectifs atteints :*

[x] Un mécanisme de déclarations explicite de variables.  
[x] Des expresssion arithmétiques arbitraire de type calculatrice.  
[x] Des lectures ou écritures mémoires via des affectations avec variables utilisateurs ou pointeurs.  
[x] Des structures de contrôles classiques( conditionelles et boucles).  
[x] Un mécanisme de typage simple comprenant notamment des entiers int et des pointeurs int *.  
[x] Définitions et appels de fonctions récursives.


*Compilation et exécution :*

    -Pour compiler le projet : Make 
    -pour  lancer les tests du projet : make test 
    -Pour générer les fichier .c et  .h et les compiler avec gcc: ./compile.sh file_name.myc
    -pour supprimer les exécutables : Make clean 

