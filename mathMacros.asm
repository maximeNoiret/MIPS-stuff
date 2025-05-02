.text

.macro dumbPowerI(%number, %power)
	storeStack($a0)
	storeStack($a1)
	
	li		$a0,	%number
	li		$a1,	%power
	jal		dumbPower
	
	loadStack($a1)
	loadStack($a0)
.end_macro

.macro powerI(%number, %power)
	storeStack($a0)
	storeStack($a1)
	
	li		$a0,	%number
	li		$a1,	%power
	jal		power
	
	loadStack($a1)
	loadStack(	$a0)
.end_macro