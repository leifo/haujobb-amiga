
Hallo Noname!

Hier kommt der Profiler. Vielleicht kannst Du ja was damit anfangen.

Kleine DOCS:
Einfach "_PR_Profiler.x" includen, ausserdem muss irgendwo eine Variable
_SO_IntuiBase mit der IntuitionBase gefuellt sein. (Kannst Du ja auf
dein Demosystem anpassen!)

Benutzt wird das ganze z.B. wie folgt:


;--------------------------------
	include "_PR_Profiler.x"

Profiler=3

Start:

.loop:
	START_PROFILE 1,"Routine 1"
	bsr R1
	END_PROFILE 1

	START_PROFILE 2,"Routine 2"
	bsr R2
	END_PROFILE 2

	START_PROFILE 3,"Routine 3"
	bsr R3
	END_PROFILE 3

	btst #6,$bfe001
	bne.b .loop

	bsr _PR_ProfileEnd		;Gibt den Requester aus!	


	rts


Wichtig ist, dass die Konstante "Profiler" immer mindestens den Wert der
Anzahl der tatsaechlichen Profile hat. Wenn ich in obigem Beispiel zB
Profiler=2 einsetzen wuerde, wird wahrscheinlich alles Abschmieren. 
Profiler=4 macht allerdings nichts.
Wenn "Profiler" nicht definiert ist (also zB ; davor), passiert gar nichts,
d.h. es wird weder gemessen noch ein Requester ausgegeben. Gut fuer final
versions.

Das Fenster am Ende sieht dann zB so aus:


		Profiling Results
===========================================================
 Routine 1:    10000 탎 (50.0%)      20000 탎 (50.0%) 
 Routine 2:     5000 탎 (25.0%)      10000 탎 (25.0%)
 Routine 3:     5000 탎 (25.0%)      10000 탎 (25.0%)
-----------------------------------------------------------
     Total:    20000 탎 (1.00f)      40000 탎 (2.00f)

Dabei ist die linke Spalte die spalte mit der geringsten Gesamt-
zeit und die Spalte rechts Maximalzeit. 20000탎 = 1 frame (PAL)
Die Zahlen in Klammern geben immer den Anteil an der Gesamtzeit an,
in der letzten Zeile die gesamte Zeit in Frames.

Viel Spass damit!

Spin.
