#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
OUTPUT="$PWD/output"
DB="/DEFINIR_LOCAL_DO_BANCO"
function check {
    if [ -f `which sqlite3` ]; then
        clear
        echo "------------------by Cristianovisk----------------------"
        echo "--------------------------------------------------------"
        echo "--- Extrair Thumbnails de Banco de Dados do WhatsApp ---"
        echo "--------------------------------------------------------"
        echo "--------------------------------------------------------"
        if [ -f msgstore.db ];
        then
            if [ `file msgstore.db | cut -d " " -f 2` == "SQLite" ];
            then
                echo -e "${RED}*** ENCONTRADO ARQUIVO SQLite VÁLIDO NO DIRETÓRIO ATUAL ***${NC}";
                DB="$PWD/msgstore.db"
            fi
        fi;
    else
        echo "SQLite3 não encontrado, tentando instalar (sudo apt install sqlite3)"
        sudo apt-get install sqlite3 -y;
    fi
}
check
check

function menu {
    echo "***************************************"
    echo "| Banco de Dados: $DB"
    echo "| Diretorio de Saida das Imagens: $OUTPUT"
    echo "***************************************"
    if [ -f $DB ]; then echo -e "Quantidade de Imagens Encontradas no Banco: ${GREEN}$(sqlite3 $DB "SELECT count(thumbnail) FROM message_thumbnails")${NC}"; 
    else echo "-"; fi
    echo "1) Indicar outro arquivo de banco"
    echo "2) Indicar outro diretorio de saida"
    echo "3) Extrair"
    echo "4) Sair"
    read item
}

function extract {
    count=0
    total=$(sqlite3 $DB "SELECT count(thumbnail) FROM message_thumbnails")
    for i in `sqlite3 $DB "SELECT quote(thumbnail) FROM message_thumbnails" | cut -d\' -f2`;
    do 
        clear
        let "count++"
        echo -e "Extraindo ${RED}$count ${NC}de ${GREEN}$total ${NC}arquivos"
        printf $i | xxd -r -p > /tmp/img.jpg 
        mv /tmp/img.jpg $OUTPUT/$(md5sum /tmp/img.jpg | cut -d " " -f 1).jpg 2> /dev/null;
    done
    clear
    echo "FORAM EXTRAIDOS ${GREEN}$count${NC} ARQUIVOS DE IMAGEM EM $OUTPUT"
    sleep 5
    exit
}
menu
#### CONDICIONAIS MENU ####
if [ $item -eq 1 ] ; then echo "Digite o diretorio do arquivo desejado: "; read DB; menu; fi
if [ $item -eq 2 ] ; then echo "Digite o diretorio de saida desejado: "; read OUTPUT; menu; fi
if [ $item -eq 4 ] ; then exit; fi
if [ $item -eq 3 ];
then
    if [ -d $OUTPUT ]; then "Extraindo em: $OUTPUT"; else echo "Diretorio não existe, criando..." && mkdir $OUTPUT && echo "Extraindo em: $OUTPUT"; fi
    if [ -f $DB ]; then if [ `file $DB | cut -d " " -f 2` == "SQLite" ]; then echo "Arquivo Validado" && extract; else echo "Arquivo Invalido" && menu; fi; else echo "Arquivo não existe" && menu; fi;
fi
