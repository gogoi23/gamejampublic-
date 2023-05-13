extends Node2D

func updateAmmo(AmmoValue,MagazineValue,MagazineCapacity):
	$Magazine.text = "Magazine:"+ str(MagazineValue)+ "/" + str(MagazineCapacity)
	$ammo.text =  "Ammo:"+ str(AmmoValue) 
	if MagazineValue <= 0:
		$reload.visible = true
	else:
		$reload.visible = false

func displayNoBullets():
	$noBullets.visible = true
	$OutofBullets.start()

func _on_OutofBullets_timeout():
	$noBullets.visible = false
	$OutofBullets.stop()

func updateStamina(stamina):
	if stamina <= 0:
		$OutOfStamina.visible = true
	else:
		$OutOfStamina.visible = false
	$StaminaBar.value = stamina
