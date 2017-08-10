/obj/item/weapon/spacecash
	name = "space cash"
	desc = "It's worth 1 credit."
	gender = PLURAL
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash"
	opacity = 0
	density = 0
	anchored = 0.0
	force = 0
	throwforce = 0
	throw_speed = 2
	throw_range = 2
	w_class = 1.0
	var amount = 1

/obj/item/weapon/spacecash/New(var/loc, var/cash=null)
	..()
	if (cash)
		src.amount = cash
	update_icon()
	desc = "It's worth [amount] credits."
	return

/obj/item/weapon/spacecash/c10
	icon_state = "spacecash10"
	amount = 10
	desc = "It's worth 10 credits."

/obj/item/weapon/spacecash/c20
	icon_state = "spacecash20"
	amount = 20
	desc = "It's worth 20 credits."

/obj/item/weapon/spacecash/c50
	icon_state = "spacecash50"
	amount = 50
	desc = "It's worth 50 credits."

/obj/item/weapon/spacecash/c100
	icon_state = "spacecash100"
	amount = 100
	desc = "It's worth 100 credits."

/obj/item/weapon/spacecash/c200
	icon_state = "spacecash200"
	amount = 200
	desc = "It's worth 200 credits."

/obj/item/weapon/spacecash/c500
	icon_state = "spacecash500"
	amount = 500
	desc = "It's worth 500 credits."

/obj/item/weapon/spacecash/c1000
	icon_state = "spacecash1000"
	amount = 1000
	desc = "It's worth 1000 credits."

//shekelmancy

/obj/item/weapon/spacecash/attackby(obj/item/W as obj, mob/user as mob, params)
	if (istype(W, src.type))
		var/obj/item/weapon/spacecash/S = W
		src.amount += S.amount
		desc = "It's worth [src.amount] credits."
		S.update_icon()
		user << "<span class='notice'>You join the two stacks of spacecash into a pile worth [src.amount].</span>"
	else
		..()

/obj/item/weapon/spacecash/attack_self(mob/user as mob)
	interact(user)

/obj/item/weapon/spacecash/interact(mob/user as mob)
	var/split_amount = min(max(round(input(usr, "Splitting Spacecash.", "How much Spacecash to remove from the pile?") as num|null), 0), amount)
	var/obj/item/weapon/spacecash/new_cash = new src.type( user, split_amount)
	amount -= split_amount
	user.put_in_hands(new_cash)
	return

/obj/item/weapon/spacecash/update_icon()
	if(amount<10)
		icon_state = "spacecash"
		return
	if(amount<20)
		icon_state = "spacecash10"
		return
	if(amount<50)
		icon_state = "spacecash20"
		return
	if(amount<100)
		icon_state = "spacecash50"
		return
	if(amount<200)
		icon_state = "spacecash100"
		return
	if(amount<500)
		icon_state = "spacecash200"
		return
	if(amount<1000)
		icon_state = "spacecash500"
		return
	//nothing else applied, so you're rich, I guess
	icon_state = "spacecash1000"

/obj/item/weapon/spacecash/proc/pay(var/price=null)
	if(price>amount)
		return 0
	else
		amount -= price
		return 1
