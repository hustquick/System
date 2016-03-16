function c  = LogMean( a, b )
%A simple function provide the log mean number of given two numbers
    if (a .* b > 0)
        c = (a - b) / log(a/b);
    else
        error('The two numbers are wrong!');
    end
end

