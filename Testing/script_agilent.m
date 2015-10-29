% Find a tcpip object.
ip = '10.128.3.199';
port = 5025;

fgen = instrfind('Type', 'tcpip', 'RemoteHost', ip, 'RemotePort', port, 'Tag', '');

if isempty(fgen)
    fgen = tcpip(ip, port);
else
    fclose(fgen);
    fgen = fgen(1)
end

fgen.Timeout = 15;
set (fgen,'OutputBufferSize',125);

fopen(fgen);
fprintf (fgen, '*IDN?');
idn = fscanf (fgen);
fprintf (idn)

fprintf (fgen, '*RST');
fprintf (fgen, '*CLS');

fprintf (fgen, 'FUNCtion SINusoid'); % Other options are SQUare, RAMP, PULSe, NOISe, DC, and USER
%fprintf (fgen, 'FUNCtion PULS');
fprintf (fgen, 'FREQuency 1');
%fprintf (fgen, 'SOURce 1:FUNCtion:PULSe:WIDTh 500000');
%fprintf (fgen, 'DCYCle MAX');

fprintf(fgen, 'SYST:ERR?');
errorstr = fscanf (fgen);

fprintf (fgen, 'FREQuency 100');

% fprintf (fgen, 'FREQuency 10000');
% fprintf (fgen, 'VOLTage:UNIT Vpp');
fprintf (fgen, 'VOLTage 1.2');
fprintf (fgen, 'OUTput:LOAD MAX');
    fprintf (fgen, 'FUNCtion DC');
for i=0:0.0001:5
    fprintf (fgen, ['SOURCE1:VOLT:OFFSET ' num2str(i)]);
    pause;
end

    fprintf (fgen, 'OUTPut ON');
fclose(fgen);
