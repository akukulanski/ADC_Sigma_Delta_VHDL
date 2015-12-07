close all;
clear;
%%%%%% CIC parametros %%%%%%
M=1;%retardo antes de restar(en el comb)
N=6;%etapas CIC
R=512;%decimacion
fs=45.3125e6;%frec sampling
%frec salida 160e3
fp=11e3/fs;%frec corte normalizada a fs;
fo=1/R;%centro primer zona de alias normalizada a fs (es el M-esimo cero)
f1=1/(M*R);%primer cero
Fs = fs; % frec sampling
Bin=1; %bits entrada
Bout=16; %bits salida recortado

Fo = 0.99*R*20e3/90.6e6; % frecuencia de corte normalizada a fs/R
%la formula es 0.22, se la puso asi para concuerde con FIR usado.

%%%%%%% fir2 parametros %%%%%%
B = 16; % Cantidad bits coeficientes
L = 255; % Orden filtro
Window=kaiser(L+1,9); %ventana usada en el filtro fir
%con estos parametros atenua 87dB a partir de 22.2KHz
%otras ventanas: chebwin(L+1,90)

%% Graficos(comentar si molestan)
F=linspace(0,fp,1000);
Hmax=N*20*log(M*R)/log(10);
H=N*10*log((sin(pi*F*M*R)./sin(pi*F)).^2)/log(10)-Hmax;
figure(1);
subplot(2,1,1), plot(fs*F/1e3,H) %banda paso
xlabel('frec[kHz]','FontSize',16);%,'FontWeight','bold');
ylabel('(H_{CIC}/H_{MAX})[dB]','FontSize',16);%,'FontWeight','bold');
set(gca,'fontsize',16);
Fa=linspace(fo-fp,fo+fp,1000);
Ha=N*10*log((sin(pi*Fa*M*R)./sin(pi*Fa)).^2)/log(10)-Hmax;
subplot(2,1,2), plot(fs*Fa/1e3,Ha) %primer zona alias, relativa a ganancia banda paso
xlabel('frec[kHz]','FontSize',16);%,'FontWeight','bold');
ylabel('(H_{CIC}/H_{MAX})[dB]','FontSize',16);%,'FontWeight','bold');
set(gca,'fontsize',16);
F2=linspace(f1,2*f1,1000);
H2=N*10*log((sin(pi*F2*M*R)./sin(pi*F2)).^2)/log(10)-Hmax;
%figure(2);
%plot(F2,H2)%segundo lobulo, relativo a ganancia banda paso

%% calculo del alias
Fali=fo-fp;
Hali=(sin(pi*Fali*M*R)./(sin(pi*Fali))).^N;
PrimerAlias= 10*log(Hali^2)/log(10)-Hmax

%% atenuacion minima en banda atenuaci�n
fat=3/2*f1;
Hmin=(sin(pi*fat*M*R)./(sin(pi*fat))).^N;
Atmin= 10*log(Hmin^2)/log(10)-Hmax

%% Atenuacion m�xima banda paso(la recompone el fir)
Hfp=(sin(pi*fp*M*R)./(sin(pi*fp))).^N;
Atmax= 10*log(Hfp^2)/log(10)-Hmax

%% Recorte de bits por etapa en el filtro CIC
Bgr=ceil(N*log(R*M)/log(2)); %crecimiento bits (bits growth)
Bt=Bin+Bgr-Bout; %total de bits a descartar
sigma_t=sqrt(2^(2*Bt)/12); %ruido de cuantizaci�n si se los sacara todos los bits
%al final

F=zeros(1,2*N);
% Calculo de los Fj
for j=N+1:1:2*N %para 2*N-j+1 combs y ningun integrador
    h_sub_j=zeros(1,2*N+1-j+1+1);
    for k=0:(2*N+1-j)
        h_sub_j(k+1)=(-1)^k*nchoosek(2*N+1-j,k);
    end
    F(j)=sqrt(sum(h_sub_j.^2));
end

for j = N:-1:1  %para N-j+1 integradores y N combs
    h_sub_j=zeros(1,(R*M-1)*N + j -1+1);
    for k = 0:(R*M-1)*N + j -1
        for m = 0:floor(k/(R*M)) % Use "m" for loop variable
            Change_to_Result = (-1)^m*nchoosek(N, m)*nchoosek(N-j+k-R*M*m,k-R*M*m);
            h_sub_j(k+1) =  h_sub_j(k+1) + Change_to_Result;
        end % End "m" loop
    end % End "k" loop
    F(j) = sqrt(sum(h_sub_j.^2));
end % End "j" loop
%en los h_sub_j quedo el caso n=1, o sea los coeficientes del filtro

% cantidad de bits a descartar en cada etapa
B_descartar= [floor((-log(F)+log(sigma_t)+log(6/N)/2)/log(2)) Bt];
%el �ltimo es el total a descartar
B_descartar(B_descartar<0)=0;
B_descartar(1)=0;%descartar en el primer integrador produce un error enorme en la media
Bits_etapa=Bin+Bgr-B_descartar
E=2.^(B_descartar);
E(E==1)=0;%cuando B es cero el error es 0
media_error=((R*M)^N*E(1)/2+E(2*N)/2)/2^Bt % el primer sumando debe dar 0
desvio_error= sqrt(sum((E.*[F 1]).^2/12))/2^Bt


%% Filtro de compensaci�n FIR
p = 2e3; % Granularity
s = 0.25/p; % Step size

fpass = 0:s:Fo; % banda de paso
fstop = (Fo+s):s:0.5; % banda de atenuacion
f = [fpass fstop]*2; % vector frecuencia normalizada
Mp = ones(1,length(fpass)); % respuesta banda paso; Mp(1)=1
Mp(2:end) = abs( M*R*sin(pi*fpass(2:end)/R)./sin(pi*M*fpass(2:end))).^N;
Mf = [Mp zeros(1,length(fstop))];
f(end) = 1;
h = fir2(L,f,Mf,Window); %% Filter length L+1

% Redondeando a enteros
hz = h/max(abs(h));

%el maximo del valor absoluto era positivo o negativo?
abs_max_positive=0;%false
for i=1:1:length(hz)
    if hz(i)==1
        abs_max_positive=1;%true
    end
end


if abs_max_positive==1 %caso positivo(o ambos iguales)
    hz = round(hz*(power(2,B-1)-1));
else%caso negativo(solo)
    hz = round(hz*power(2,B-1));
end



FIRcomp_f=dfilt.dffir(hz);
%%CIC_f=dfilt.dffir(h_sub_j);
[H_FIR,W]=freqz(FIRcomp_f,1000);
freqz(FIRcomp_f);
H_CIC=(sin(W*M/2)./(sin(W/(2*R)))).^N;
figure(4);
plot(W*fs/R/2/pi,20*log(abs(H_CIC.*H_FIR))/log(10));
