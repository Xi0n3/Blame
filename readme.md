Este proyecto, titulado "Blame", es un programa desarrollado en Godot, 
un motor de videojuegos de código abierto, utilizando tecnologías 
basadas en Python, como GDScript. Además, se han empleado modelos, 
animaciones y texturas libres, provenientes de fuentes como Sketchfab, 
Kenney y Mixamo.

El proyecto es un prototipo muy temprano de lo que se busca lograr: un
videojuego multijugador local. Actualmente, el prototipo permite conectar
dos mandos (Xbox, PlayStation, Nintendo Switch o genéricos) y distinguir
los inputs de cada jugador. Asimismo, si se prefiere, es posible usar el
teclado como control para cualquiera de los dos jugadores.

El jugador puede caminar, correr o esprintar (botón trasero derecho o tecla 
Shift) y atacar (botón Y/X o tecla F). Aunque las acciones disponibles son
simples, internamente se implementó un robusto sistema de máquina de estados,
lo que facilita la modularización y expansión del código de manera sencilla
y comprensible.

Estas acciones permiten interactuar con las mecánicas del nivel prototipo.
Por ejemplo, al atacar se pueden activar o desactivar mecanismos dentro del entorno.

El Jugador 1 tiene energía azul, mientras que el Jugador 2 tiene energía
amarilla. Existen dos tipos de accionadores correspondientes a cada jugador,
que solo pueden ser activados al ser golpeados por el jugador asignado.
Esto permite transferir energía a puertas, escaleras o plataformas, haciendo
que dejen de ser objetos físicos (colisionables) y puedan atravesarse, o viceversa.
Además, si ambos jugadores activan simultáneamente sus respectivos accionadores,
se desactiva la energía, haciendo que todos estos objetos vuelvan a ser sólidos.
Este estado de la mazmorra es esencial para poder completarla.

El objetivo principal de este prototipo es que los dos jugadores se reúnan al final
de la mazmorra. Para lograrlo, deberán resolver el puzzle colaborativo, lo cual
requiere comunicación y coordinación constante entre ambos.
