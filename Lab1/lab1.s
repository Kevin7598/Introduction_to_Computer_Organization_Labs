addi x18, x0, 2
# set the size of the array
add x19, x0, x0
# set hotday
add x20, x0, x0
# set coldday
add x21, x0, x0
# set comfortday
add x22, x0, x9
# set base address of the array, x9 is the array and x22 is the base address
slli x18, x18, 2
# set offset
add x23, x22, x18
# set destination address
addi x25, x0, 1
addi x26, x0, 30
addi x27, x0, 17
addi x28, x0, 5
addi x29, x0, -18
addi x7, x0, 0
sw x25, (0)x9
sw x26, (4)x9
#addi x24, x0, -1
jal x0, Loop


#Loop:
#addi x28, x0, 1
#beq x24, x28, Hotcount
#addi x29, x28, -2
#beq x24, x29, Coldcount
#addi x30, x29, 1
#beq x24, x30, Comfortcount

Loop:
lw x5, (0)x22
addi x6, x0, 30
bge x5, x6, Hot1
addi x6, x0, 5
bge x5, x6, Comfort1
blt x5, x6, Cold
addi x22, x22, 4
beq x22, x23, Exit
jal x0, Loop

#Comfortcount:
#lw x5, (0)x22
#addi x6, x0, 5
#bge x5, x6, Comfort1
#addi x22, x22, 4
#beq x22, x23, Exit
#jal x0, Comfortcount

Comfort1:
lw x5, (0)x22
addi x6, x0, 5
bne x5, x6, Comfort2
beq x5, x6, Cold
#addi x22, x22, 4
#beq x22, x23, Exit
#jal x0, Comfortcount

Comfort2:
lw x5, (0)x22
addi x6, x0, 30
blt x5, x6, Comfort3
bge x5, x6, Hot1
#addi x22, x22, 4
#beq x22, x23, Exit
#jal x0, Comfortcount

Comfort3:
addi x21, x21, 1
addi x22, x22, 4
beq x22, x23, Exit
jal x0, Loop

#Hotcount:
#lw x5, (0)x22
#addi x6, x0, 30
#bge x5, x6, Hot1
#addi x22, x22, 4
#beq x22, x23, Exit
#jal x0, Hotcount

Hot1:
addi x19, x19, 1
addi x22, x22, 4
beq x22, x23, Exit
jal x0, Loop

#Coldcount:
#lw x5, (0)x22
#addi x6, x0, 5
#blt x5, x6, Cold
#beq x5, x6, Cold
#addi x22, x22, 4
#beq x22, x23, Exit
#jal x0, Coldcount

Cold:
addi x20, x20, 1
addi x22, x22, 4
beq x22, x23, Exit
jal x0, Loop

Exit:
add x20, x20, x0