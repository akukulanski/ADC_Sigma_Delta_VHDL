function [ fgen ] = open_gen( ip )
    if (nargin < 1) 
        ip = '10.128.3.199';
    end
    
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

    fprintf (fgen, 'FUNCtion SINusoid'); 
    fprintf (fgen, 'FREQuency 1000');
    fprintf (fgen, 'VOLTage:UNIT Vpp');
    fprintf (fgen, 'OUTput:LOAD MAX');
    fprintf (fgen, 'VOLTage 1.2');    
end

