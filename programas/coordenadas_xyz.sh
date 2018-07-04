	#******* Programa para graficar la distribucion de iones en funcion de la distancia al eje z de la proteína *************

workdir="/home/vanesa/mutaciones/resultados/new_WT/analisis/pdb_WT/solo_coordenadas" #path del directorio con la carpeta del programa
mkdir $workdir

#Numero de frames a procesar
p="1"
f="350"


#genero los archivos de ptraj para calcular el centro de la esfera

ptraj_inputs="$workdir/ptraj"
mkdir $ptraj_inputs
#variables para correr el cpptraj
topology="/home/vanesa/mutaciones/resultados/new_WT/new_WT.prmtop"
traj="/home/vanesa/mutaciones/resultados/new_WT/new_WT.traj"

#..................................................................................................................
#Genero los inputs para correr el ptraj:

cd $ptraj_inputs

for ((y="$p"; y<="$f"; y++))
        do
        pdb=$topology
	name="open_"$y".pdb"
        trayectoria=$traj
        cat >$ptraj_inputs/ptraj_"$y".in <<EOF
        parm $pdb
        trajin $trayectoria $y $y 1
	center :51,431,811 origin mass        
	trajout $name 
	go
EOF
done

for ((y="$p"; y<="$f"; y++))
do

cpptraj -i ptraj_"$y".in

done

mv open*.pdb $workdir
cd $workdir
rm -rf $ptraj_inputs
