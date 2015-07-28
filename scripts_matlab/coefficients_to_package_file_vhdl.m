function [] = coefficients_to_package_file_vhdl( coefficients,B,FileName)

h = coefficients/max(abs(coefficients));

%el maximo del valor absoluto era positivo o negativo?
abs_max_positive=0;%false
for i=1:1:length(h)
    if h(i)==1
        abs_max_positive=1;%true
    end
end

if abs_max_positive==1 %caso positivo(o ambos iguales)
    h = round(h*(power(2,B-1)-1));
else%caso negativo(solo)
    h = round(h*power(2,B-1));
end
h(h==-0)=0;% me molesta el -0
fileID=fopen(FileName,'w');%abro archivo
%escribo la es
fprintf(fileID,'library ieee;\nuse ieee.numeric_std.all;\n\npackage my_coeffs is\n\tconstant B: natural:=%.0f;\n\tconstant N_coeffs: natural := %.0f;\n\ttype coeff_t is array (N_coeffs-1 downto 0) of integer range -2**(B-1) to 2**(B-1)-1;\n\tconstant coefficients: coeff_t:=\n\t\t(',B,length(coefficients));
if floor(length(coefficients)/20)~=length(coefficients)/20
    final=floor(length(coefficients)/20);
else
    final=floor(length(coefficients)/20)-1;
end
for i=1:1:final
    fprintf(fileID,'%.0f,',h((1+20*(i-1)):20*i));%pone los coeficientes separados por ',' de a 20
    fprintf(fileID,'\n\t\t');
end
%los ultimos a imprimir
fprintf(fileID,'%.0f,',h((20*final+1):(length(coefficients)-1)));
fprintf(fileID,'%.0f\n\t\t',h(length(coefficients)));%el que va sin ','

fprintf(fileID,');\nend package my_coeffs;');

end

