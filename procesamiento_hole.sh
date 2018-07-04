#Directorio principal
workdir="/home/vanesa/PROCESAMIENTO/mutacion_DyE/fig" #Path de la carpeta que contiene el programa y los dos .exe necesarios
mkdir $workdir

#Directorio donde se encontrara la salida del programa

carpeta_final="/home/vanesa/PROCESAMIENTO/mutacion_DyE/figura_hole" # --->NOMBRAR
mkdir $carpeta_final

frames="501" #número de frames de cada archivo.traj 
inc="y+=500" #intervalo del incremento

########################## Defino los directorios de trabajo y las variables  ####################################

#CPPTRAJ: 

ptraj_inputs="$workdir/ptraj"
dir_trajfiles="/home/vanesa/PROCESAMIENTO/mutacion_DyE" #COMPLETAR:Path del directorio donde se encuentran los archivos.traj a analizar
#inicial="/home/vanesa/PROCESAMIENTO/inicial.pdb"
#variables para correr el cpptraj
dir_pdb_top="/home/vanesa/PROCESAMIENTO/mutacion_DyE/mut_DyE.prmtop" #Path del directorio que contiene el PDB que se usará como archivo de coord (controlar que el NA=NA en la traj)
#referencia="/home/vanesa/PROCESAMIENTO/NaCl_closed/equil/referencia.pdb" #referencia para alinear en ptraj debe tener el mismo nro de átomos que la trayectoria.


#HOLE:

hole_inputs="$workdir/hole_inputs"
#variables para correr el hole
radius="/share/apps/hole2/rad/simple.rad"

directorio_esferas="$hole_inputs/directorio_esferas"



#ANALISIS:
analisis="$workdir/analisis"

mkdir $ptraj_inputs
mkdir $hole_inputs
mkdir $analisis
mkdir $directorio_esferas


#COPIAR los programas min.exe y valz.exe AL DIRECTORIO DE ANALISIS:

cp min.exe $analisis

#copio los trajectory a la carpeta donde voy a correr el ptraj:

cp $dir_pdb_top $ptraj_inputs


#loops para crear los archivos de input del ptraj

cd $ptraj_inputs

for ((y=1; y<=$frames; $inc))
do
        pdb=$dir_pdb_top
        name=prod_"$y".pdb
	reference=$inicial
        trayectoria=$dir_trajfiles/procesamiento.traj
        cat >$ptraj_inputs/ptraj_"$y".in <<EOF
        parm $pdb
        trajin $trayectoria $y $y 1
	strip ':1-327, :361-702, :736-1077, :1111-3115'
        strip ':WAT'
	center origin 
	trajout $name 
	go
EOF

done
#Guardar!
#reference $referencia

#Esto es para correr el cpptraj: 

for ((y=1; y<=$frames; $inc))
do
input=$ptraj_inputs/ptraj_"$y".in
cpptraj -i $input

done

#Genero los archivos de input para ejecturar el HOLE:

cd $hole_inputs

for ((y=1; y<=$frames; $inc))
do

name=$ptraj_inputs/prod_"$y".pdb
cat >$hole_inputs/hole_"$y".in <<EOF

coord $name
radius $radius
cvect 0 0 1
!cpoint 6 3 37 
endrad 20 
!optional cards:
sphpdb esferas.sph   
                                        
EOF
done

#Ejecuto el HOLE:


for ((y=1; y<=$frames; $inc))
        do
        hole <hole_"$y".in > hole_"$y".txt
        mv hole_"$y".txt $analisis
        mv esferas.sph esferas_"$y".sph
 	mv esferas_"$y".sph $directorio_esferas
done

cd $directorio_esferas 

for ((y=1; y<=$frames; $inc))
do
sph_process -sos -dotden 15 -color esferas_"$y".sph solid_surface.sos
sos_triangle -s < solid_surface.sos > solid_surfaces_"$y".vmd_plot 
sph_process -dotden 15 -color esferas_"$y".sph esferas_"$y".qpt
#time sos_triangle -s < solid_surface.sos > solid_surfaces_"$y".vmd_tri

done


#copio el directorio de trabajo a la carpeta final

mv $workdir $carpeta_final
