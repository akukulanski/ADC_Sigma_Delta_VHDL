function [ conf ] = gen_config(fgen, varargin )

    narg = length(varargin);
    
    if (narg <2)
        fprintf('Ingrese correctamente los argumentos\n');
        return;
    end
    
    p = inputParser;
    p.addParamValue('type', [], @(x)( ischar(x) || isempty(x) ));
    p.addParamValue('vpp', [], @(x)( isnumeric(x) || isempty(x) ));
    p.addParamValue('offset', [], @(x)( isnumeric(x) || isempty(x) ));
    p.addParamValue('freq', [], @(x)( isnumeric(x) || isempty(x) ));
    p.addParamValue('state', [], @(x)( ischar(x) || isempty(x) ));
    p.parse(varargin{:});
    
    conf = p.Results;
    clear p;
    
    if (isempty(conf.type))
        fprintf('Argumento type debe existir\n');
        return;
    end
    
    
    fprintf (fgen, 'OUTPut OFF');
   
    
    switch conf.type
        case 'sin'
            if (isempty(conf.vpp) || isempty(conf.offset) || isempty(conf.freq)  )
                fprintf('Argumentos incompletos\n');
                return;
            end
            
            fprintf (fgen, 'FUNCtion SINusoid'); 
            fprintf (fgen, ['FREQuency ' num2str(conf.freq)]);
            fprintf (fgen, 'VOLTage:UNIT Vpp');
            fprintf (fgen, 'OUTput:LOAD MAX');
            fprintf (fgen, ['VOLTage ' num2str(conf.vpp)]);   
            fprintf (fgen, ['SOURCE1:VOLT:OFFSET ' num2str(conf.offset)]);
        case 'dc'
            if (isempty(conf.offset))
                fprintf('Argumentos incompletos\n');
                return;
            end 
            fprintf (fgen, 'FUNCtion DC'); 
            fprintf (fgen, 'OUTput:LOAD MAX');
            fprintf (fgen, ['SOURCE1:VOLT:OFFSET ' num2str(conf.offset)]);
                
    end
    
    
    if (isempty(conf.state))
        fprintf (fgen, 'OUTPut OFF');
    else
        if (strcmp(conf.state,'on'))
           fprintf (fgen, 'OUTPut ON');
        else
           fprintf (fgen, 'OUTPut OFF');
        end
    end


end

