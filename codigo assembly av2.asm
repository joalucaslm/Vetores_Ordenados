.data
#Arquivos
input_file:          .asciiz  "C:\\Users\\joaol\\Desktop\\Codigo Assembly av2\\lista.txt"
output_file:         .asciiz  "C:\\Users\\joaol\\Desktop\\Codigo Assembly av2\\lista_ordenada.txt"
                     .align 2
#Buffers
input_buffer:        .space 1024  # espaço para leitura do arquivo
num_list:            .space 1024  # espaço para lista de números
output_buffer:       .space 32    # espaço para conversão e escrita
char_buffer:         .space 1024  # espaço para lista de caracteres

.text
start:
    # Open file
    li      $v0, 13               
    la      $a0, input_file       
    li      $a1, 0               
    li      $a2, 0               
    syscall
    move    $s2, $v0

    # Read file
    li      $v0, 14              
    move    $a0, $s2           
    la      $a1, input_buffer     
    li      $a2, 1024           
    syscall
    move    $s0, $v0           

    # Converter para número
    li      $s1, 0
parse_chars:
    li      $t2, 0              
    li      $t0, 0
parse_buffer:
    bge     $t2, $s0, end_parse
    lb      $t3, input_buffer($t2)     
    addi    $t2, $t2, 1
    # Pular vírgula
    li      $t9, 0x2c   # ASCII ',' 
    beq     $t3, $t9, parse_buffer
    # Sinal negativo
    li      $t9, 0x2d   # ASCII '-'
    beq     $t3, $t9, negative_value
    li      $t4, 0
    li      $t7, 0  # resetar sinal
parse_number:
    li      $t9, 0x30   # ASCII '0'
    blt     $t3, $t9, store_value
    li      $t9, 0x39   # ASCII '9'
    bgt     $t3, $t9, store_value
    # Acumulado = acumulado * 10 + (dígito - '0')
    sub     $t5, $t3, 0x30  
    mul     $t4, $t4, 10
    add     $t4, $t4, $t5
    lb      $t3, input_buffer($t2)
    addi    $t2, $t2, 1
    j       parse_number
negative_value:
    li      $t7, 1
    lb      $t3, input_buffer($t2)
    addi    $t2, $t2, 1
    j       parse_number
store_value:
    beq     $t7, 0, positive_value
    sub     $t4, $zero, $t4
positive_value:
    sw      $t4, num_list($t0)
    addi    $t0, $t0, 4
    li      $t4, 0
    li      $t7, 0  # resetar flag de sinal
    j       parse_buffer
end_parse:
    # Fechar arquivo
    li      $v0, 16
    move    $a0, $s2
    syscall

sort_values:
    # Ordenar os números
    move    $s1, $t0
    li      $t4, 0
    sub     $t5, $s1, 4
loop_1:
    bge     $t4, $t5, IntToChar_start
    sub     $t6, $t5, $t4
    li      $t0, 0
loop_2:
    bge     $t0, $t6, end_1
    lw      $t1, num_list($t0)
    add     $t2, $t0, 4
    lw      $t3, num_list($t2)
    blt     $t1, $t3, end_2
    sw      $t3, num_list($t0)
    sw      $t1, num_list($t2)
end_2:
    add     $t0, $t0, 4
    j       loop_2
end_1:
    add     $t4, $t4, 4
    j       loop_1

IntToChar_start:
    # Converter números para caracteres
    li      $t4, 0
    li      $t0, 0
restart_conversion:
    li      $t7, 0
    li      $t2, 0
check_sign:
    bgt     $t0, $s1, write_output
    lw      $t1, num_list($t0)
    add     $t0, $t0, 4
    bge     $t1, $zero, convert_number
    li      $t7, 1
    li      $t9, -1
    mul     $t1, $t1, $t9
convert_number:
    move    $t6, $t1
next_digit:
    li      $t9, 10
    div     $t6, $t9
    mfhi    $t5
    mflo    $t6
    add     $t3, $t5, 0x30
    sb      $t3, output_buffer($t2)
    add     $t2, $t2, 1
    bnez    $t6, next_digit
    beqz    $t7, sort_characters
    li      $t9, '-'
    sb      $t9, output_buffer($t2)
    add     $t2, $t2, 1
sort_characters:
    beqz    $t2, exit_conversion
    add     $t2, $t2, -1
    lb      $t3, output_buffer($t2)
    sb      $t3, char_buffer($t4)
    add     $t4, $t4, 1
    j       sort_characters
exit_conversion:
    li      $t9, 0x2c
    sb      $t9, char_buffer($t4)
    add     $t4, $t4, 1
    j       restart_conversion

write_output:
    # Inserir no arquivo lista_ordenada.txt
    li      $v0, 13
    la      $a0, output_file
    li      $a1, 1
    li      $a2, 0
    syscall
    move    $s2, $v0
    li      $v0, 15
    move    $a0, $s2
    la      $a1, char_buffer
    li      $a2, 1024
    syscall

end_program:
    li      $v0, 10
    syscall
