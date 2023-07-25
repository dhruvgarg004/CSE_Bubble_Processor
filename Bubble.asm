add $s0 , $a0, $0  #address of array in $s0
add $s1 , $a1 , $0 #size of array in $s0

addi $s2 , $s1 , -1  #i=n-1
Loop1:  beq $s2 , $0 , exit1   #exit1 when i=0
        add $s3 , $0 , $0   #j=0
        Loop2:  beq $s3 , $s2 , exit2   #exit2 when j=i
                add $t0 , $s0 , $s3     #t0 = a+j
                lw $s4 , 0($t0)     #s4 = a[j]
                lw $s5 , 1($t0)     #s5 = a[j+1]
                ble $s4 , $s5 , afterswap   #if a[j]<=a[j+1] dont swap
                sw $s4, 1($t0)
                sw $s5 , 0($t0)
                afterswap:
                addi $s3 , $s3 , 1  #j=j+1
                j Loop2
        exit2:
        addi $s2, $s2 , -1  #i = i-1
        j Loop1     #
exit1:
beq $0 , $0 , 0
