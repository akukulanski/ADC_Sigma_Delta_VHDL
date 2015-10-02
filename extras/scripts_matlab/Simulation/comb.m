function [ output ] = comb( input , bits)
    
    output = zeros(1,numel(input));
    output(1) = 0;
    
    for i=2:numel(input)
        output(i)=(input(i)-input(i-1));
    end
    output = uint64(output);

end

