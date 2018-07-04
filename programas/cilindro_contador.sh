	#********************************** Programa para contar iones dentro del a proteína  ********************************

workdir="/home/vanesa/mutaciones/nuevas/resultados/new_D51_53N/analisis/cilindro_cont/numero_de_iones" #path del directorio con la carpeta del programa
mkdir $workdir

#Numero de frames a procesar
p="1"
f="503"

#genero los archivos de ptraj para calcular el centro de la esfera

ptraj_inputs="$workdir/ptraj"
mkdir $ptraj_inputs
#variables para correr el cpptraj
topology="/home/vanesa/mutaciones/nuevas/resultados/new_D51_53N/new_D51_53N.prmtop"
traj="/home/vanesa/mutaciones/nuevas/resultados/new_D51_53N/new_D51_53N.traj"

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
        vector center :87,467,847  out centro_de_masa_inferior
	vector center :342,722,1102  out centro_de_masa_superior 
	go
EOF
done

for ((y="$p"; y<="$f"; y++))
do
cd $ptraj_inputs

cpptraj -i ptraj_"$y".in

#ojo: superior e inferior no hacen referencia a arriba y abajo en la proteína, sino al valor de z del cm de la terna de aa

awk '{print $2, $3, $4}' centro_de_masa_superior > tmp1
sed '/Vec/d' tmp1 > centro_sup_"$y".dat
cat centro_sup_"$y".dat >> all_CM_superior.dat

awk '{print $2, $3, $4}' centro_de_masa_inferior > tmp2
sed '/Vec/d' tmp2 > centro_inf_"$y".dat
cat centro_inf_"$y".dat >> all_CM_inferior.dat

rm tmp1
#rm centro_*

# Guardo solamente el tipo de resíduo, el número, y las coordenadas x,y,z de todos ellos:

sed '/TER/d' open_"$y".pdb >tmp1
sed '/CRYST1/d' tmp1 >tmp2
awk  '{line=$0; a=substr(line,18,3); b=substr(line,23,4); c=substr(line,31,8); d=substr(line,39,8); e=substr(line,47,8); printf("%8s %8s %20s %20s %20s\n", a,b,c,d,e)}' tmp2 > iones.pdb

# Coloco en un archivo nuevo todos los sodios y los cloruros que cumplen con una condición dada de Z y r:

awk '/Na+/ {if (($5>(-40)) && ($5<20) && sqrt(($3*$3)+($4*$4))<16) printf("%8s %8s %20s %20s %20s\n", $1,$2,$3,$4,$5)}'  iones.pdb >> sodios_internos_"$y".pdb

awk '/Cl-/ {if (($5>(-40)) && ($5<20) && sqrt(($3*$3)+($4*$4))<16) printf("%8s %8s %20s %20s %20s\n", $1,$2,$3,$4,$5)}'  iones.pdb >> cloruros_internos_"$y".pdb

rm tmp*
rm iones.pdb
mv sodios_internos_"$y".pdb $workdir
mv cloruros_internos_"$y".pdb $workdir

cd $workdir

# contador de iones aplicado a cada PDB:

awk 'END {print $1=NR}'  sodios_internos_"$y".pdb >> tmp_Na
awk 'END {print $1=NR}'  cloruros_internos_"$y".pdb >> tmp_Cl


awk '$1=(FNR FS $1)' tmp_Na >> tmp_Na_b
mv tmp_Na_b num_sodios_int.dat

awk '$1=(FNR FS $1)' tmp_Cl >> tmp_Cl_b
mv tmp_Cl_b num_cloruros_int.dat

done

#rm tmp*
mkdir iones_por_frame
mv sodios_internos* iones_por_frame
mv cloruros_internos* iones_por_frame

rm -rf $ptraj_inputs
