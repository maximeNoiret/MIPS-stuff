.text

.include "functionMacros.asm"
.include "mathMacros.asm"

main:
	# not printing result since it can't be stored anyway (32-bit limitation)
	print("Begin dumbPower\n")
	dumbPowerI(2, 16)
	print("End dumbPower\n")
	
	print("Begin power\n")
	powerI(2, 16)
	print("End power\n")
	exit


.include "libFunctions.asm"
.include "libMath.asm"