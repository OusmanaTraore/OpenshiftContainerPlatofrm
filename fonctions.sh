###  pause 
pause(){
    echo "Appuyer sur une touche pour continuer!"
    read x
}
#### Chose 
chooseRHCOS(){
select rhcos in RHCOS_ISO RHCOS_kernel RHCOS_initramfs RHCOS_rootfs 
do
    if [[ $rhcos = "RHCOS_ISO" ]] 
    then
        echo "you chose 1 ";
        break;
    elif [[ $rhcos == "RHCOS_kernel" ]] 
    then
        echo "you chose 2 ";
        break;
    elif [[ $rhcos == "RHCOS_initramfs" ]] 
    then
        echo "you chose 3 ";
        break;
    elif [[ $rhcos == "RHCOS_rootfs" ]] 
    then
        echo "you chose 4 ";
        break;
    else
        echo "Please select one correct option";
        chooseRHCOS 
        break;
    fi
done
}

### Compression et décompression de fichier , format gzip, bzip2
compressFile(){
    if [[ $2 == "" ]]
    then
        echo "Vous devez ajouter un format pour la compression exp: zip, ";
    elif [[ $2 == "zip" ]] || [[ $2 == "bzip" ]] 
    then
        echo "compression du fichier $1  format $2"
        echo -e "=> Voulez-vous supprimer le fichier original ?
        - o - pour supprimer l'original
        - n - pour conserver l'original
        "    
    read -p "|Votre choix> " fichier
        case $fichier in 
        o|O) 
            echo "compression en supprimant l'original"
            if [[ $2 == "zip" ]] 
            then 
                gzip $1 
            elif [[ $2 == "bzip" ]] 
            then 
                bzip2 $1
            fi
            ;;
        n|N)
            echo "compression en conservant  l'original"
            if [[ $2 == "zip" ]] 
            then 
                gzip -c $1 > $1.gz 
            elif [[ $2 == "bzip" ]] 
            then 
                bzip2 -c $1 > $1.bz2
            fi
            ;;
        *)
            echo "choix non implémenté"
            ;;
        esac
    fi
}

uncompressFile(){
    if [[ "$1" == *.gz ]]
    then
        echo "Décompression du fichier $1 "
        gunzip $1
    elif [[ "$1" == *.bz2 ]]
    then
        echo "Décompression du fichier $1 "
        bzip2 -d $1
    elif [[ "$1" == *.tar.gz ]]
    then
        echo "Décompression du fichier $1 "
        find Downloads -name *.tar.gz | gunzip -c Downloads/openshift-install-linux.tar.gz | tar xvf -

    fi
}

### Archivage 
archiveTar(){
    IFS=":"
    tab=("Creation d'une archive":"Vérification d'une archive":"Extraction d'une archive")
    select var in ${tab[*]}
    do
        echo "$var"
        if  [[ $var == "Creation d'une archive" ]]
        then
            read -p "|=> Entrez le nom de l'archive à créer >> " archive_files
            tar -cf archive.tar $archive_files
            mv archive.tar $archive_files.tar
            break;
        elif [[ $var == "Vérification d'une archive" ]]  
        then
            read -p "|=> Entrez le nom de l'archive à vérifier >> " verif_archive
            tar -tzvf  $verif_archive
            break;
        elif [[ $var == "Extraction d'une archive" ]]  
        then
            ls
            echo ""
            read -p "|=> Entrez le nom de l'archive à extraire >> " extract_archive
            tar -xzvf archive.tar $extract_archive
            break;
        fi
    done
   
}




# repeaT(){
#     path="/INETUM"
#     for i in path
#     do 
#         if [[ -f == *.yaml ]]
#         then
#              echo $i
#         fi
#     done
# }

line2(){
    echo -e "
    
    "
}

keyContinue(){
    enter=""
while [ "$enter" != "e" ]
do
 echo "======>>> Edit the file $fichier and add the correct IP > "
 vi $fichier 
 
 read -p "======>>> When done press [e] enter to continue > " enter 
 if [ "$enter" != "e" ] 
    then
    echo "you type a wrong key"
 elif [ "$enter" == "e" ];
    then
    echo " continuing..."
    sleep 1
 fi
done
}