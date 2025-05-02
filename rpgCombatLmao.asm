.data
	randomSeedSet: .asciiz "Enter random seed: "
	rpgPrompt0: .asciiz "Your HP: "
	rpgPrompt1: .asciiz " | Enemy HP: "
	rpgPrompt2: .asciiz "\n1. Attack | 2. Defend | 3. Potion ("
	rpgPrompt3: .asciiz " left)\n> "
	rpgPromptIncorrect: .asciiz "Incorrect input! Only input 1, 2 or 3!\n"
	rpgPromptAttack: .asciiz "You deal "
	rpgPromptEnemy: .asciiz "Enemy deals "
	rpgPromptDamage: .asciiz " damage!\n"
	rpgPromptDefend0: .asciiz "You defend for "
	rpgPromptDefend1: .asciiz " damage...\n"
	rpgPromptDefend2: .asciiz "The enemy is defending!\n"
	rpgPromptPlHeal: .asciiz "You have healed for "
	rpgPromptEnHeal: .asciiz "The enemy has healed for "
	rpgPromptHealHP: .asciiz " HP!\n"
	rpgPromptNoPots: .asciiz "You don't have any more potions!\n"
	rpgPromptLoss0: .asciiz "You died! The enemy had "
	rpgPromptLoss1: .asciiz " HP left.\n"
	rpgPromptWon: .asciiz "You won!\n"
	
	RNG: .word 0
	
	clearText: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

.text

.include "functionMacros.asm"

# RPG lmao
.macro printPrompt
	printString(rpgPrompt0)
	printRegInt($s0)
	printString(rpgPrompt1)
	printRegInt($s1)
	printString(rpgPrompt2)
	printRegInt($s2)
	printString(rpgPrompt3)
.end_macro

.macro setupRandom
	# ask for random seed
	li		$v0,	4
	la		$a0,	randomSeedSet
	syscall
	# get random seed
	li		$v0,	5
	syscall
	# set seed
	move	$a1,	$v0
	la		$a0,	RNG
	li		$v0,	40
	syscall
.end_macro

main:
	setupRandom
	printString(clearText)
	li		$s0,	20					# player health
	li		$s1,	50					# enemy health
	li		$s2,	3					# player potions
	li		$s3,	5					# enemy potions
	mainLoop:
	li		$s4,	0					# reset player defense at start of round
	blez	$s0,	playerLoses
	userChoices:
	printPrompt
	# get user input
	li		$v0,	5
	syscall
	printString(clearText)
	beq		$v0,	1,	playerAttacks	# if 1, player attacks
	beq		$v0,	2,	playerDefends	# if 2, player defends
	beq		$v0,	3,	playerHeals		# if 3, player uses a potion
	printString(rpgPromptIncorrect)		# if anything else, inform the user and ask again
	j		userChoices
	endOfPlayerAction:
	blez	$s1,	playerWins			# check if player won AGAIN in case enemy is already dead.
	# enemy's turn, random, but only tries potion if has any
	li		$s5,	0					# enemy defense (when defending)
	beqz	$s3,	noEnemyPots			# if enemy still has pots,
	rand(1, 4, RNG)			# let him also choose for potion
	beq		$v0,	3,	enemyHeals		# only check if he chose to heal if he CAN (so in this condition block)
	j		enemyAction
	noEnemyPots:						# else, just let him choose between Attack and Defend
	rand(1, 3, RNG)
	enemyAction:
	beq		$v0,	1,	enemyAttacks
	beq		$v0,	2,	enemyDefends
	endOfEnemyAction:
	j		mainLoop
	
	
playerAttacks:
	rand(5, 16, RNG)
	subu	$v0,	$v0,	$s5
	bgez	$v0,	playerAttackNotNegative	# if player attack becomes negative after defense
	li		$v0,	0					# set it as 0
	playerAttackNotNegative:
	subu	$s1,	$s1,	$v0			# deal the damage to the enemy
	printString(rpgPromptAttack)
	printRegInt($v0)
	printString(rpgPromptDamage)
	j		endOfPlayerAction

playerDefends:
	rand(10, 16, RNG)
	move	$s4,	$v0					# set this as next round's defense
	printString(rpgPromptDefend0)
	printRegInt($s4)
	printString(rpgPromptDefend1)
	j		endOfPlayerAction

playerHeals:
	bnez	$s2,	stillHasPotions		# if the player doesn't have any more potions,
	printString(rpgPromptNoPots)		# inform them and
	j		userChoices					# make them input action again
	stillHasPotions:
	rand(3, 11, randomSeedSet)			# else, heal them for a random amount
	printString(rpgPromptPlHeal)
	add		$s0,	$s0,	$v0			# add it to health
	printRegInt($v0)					# print amount healed
	printString(rpgPromptHealHP)
	addi	$s2,	$s2,	-1			# remove a potion
	j		endOfPlayerAction


enemyAttacks:
	rand(5, 16, RNG)
	subu	$v0,	$v0,	$s4
	bgez	$v0,	enemyAttackNotNegative	# if enemy attack becomes negative after defense
	li		$v0,	0					# set it as 0
	enemyAttackNotNegative:
	subu	$s0,	$s0,	$v0			# deal the damage to the player
	printString(rpgPromptEnemy)
	printRegInt($v0)
	printString(rpgPromptDamage)
	j		endOfEnemyAction
enemyDefends:
	rand(10, 16, RNG)
	move	$s5,	$v0					# set this as next round's defense
	printString(rpgPromptDefend2)
	j		endOfEnemyAction
enemyHeals:
	rand(3, 11, RNG)			# else, heal them for a random amount
	printString(rpgPromptEnHeal)
	add		$s1,	$s1,	$v0			# add it to health
	printRegInt($v0)					# print amount healed
	printString(rpgPromptHealHP)
	addi	$s3,	$s3,	-1			# remove a potion
	j		endOfEnemyAction

playerLoses:
	printString(rpgPromptLoss0)
	printRegInt($s1)
	printString(rpgPromptLoss1)
	exit

playerWins:
	printString(rpgPromptWon)
	exit
	