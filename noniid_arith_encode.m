function y = noniid_arith_encode(x, prob, key_len, keySet, alphabet)
% arith_encode(x,p) implements the binary arithmetic encoder for the source
% sequence x using the memoryless probability model p.
%
% Copyright Jossy 1994, inspired by Witten, Neal & Cleary 1987


% define the integer versions of 1.0, 0.5, 0.25 and 0.75
precision = 64;
one = 2^precision-1; % this is max_integer
quarter = ceil(one/4);
half = 2*quarter;
threequarters = 3*quarter;


% initialise output string, interval end-points and straddle counter
y = [];
lo = 0;
hi = one;
straddle = 0;

% define alphabet
alphabet = (0:255);


% MAIN ENCODING ROUTINE
for k = 1:length(x) % for every input symbol
    
    
    %define conditional/unconditional p based on k
    if k<=key_len
        p = sum(prob)/sum(sum(prob));   %use unconditional probability for the first few symbols
    else
        key = x(k-key_len:k-1);
        [dummy,ind_key] = ismember(key,keySet,'rows');               %conditional prob defined by key
        p = prob(ind_key, :);
        p = p/sum(p);
        
    end     
    
    % calculate the cumulative probability distribution
    f = cumsum(p(:));
    f = [0 ; f((2:end)-1)];
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Code beyond this point is unchanged from arithmetic encoder  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % 1) calculate the interval range to be the difference between hi and lo + 1
    % The +1 is necessary to avoid rounding issues
    %
    % ....
    range = hi - lo + 1; 
    
    
    % The following command finds the index of the next input symbols in
    % the cumulative probability distribution f
    ind = find(alphabet == x(k));   
    
    
    
    % 2) narrow the interval end-points [lo,hi) to the new range [f,f+p]
    % within the old interval [lo,hi], being careful to round 'innwards' so
    % the code remains prefix-free (you want to use the functions ceil and
    % floor). This will require two instructions
    %
    % ...
    % ...   
    lo=lo+ceil(range*f(ind));
    hi=lo+floor(range*p(ind));
    
    
    % check that the interval has not narrowed to 0
    if (hi == lo)
        error('Interval has become zero: check that you have no zero probs and increase precision');
    end
    
    % Now we need to re-scale the interval if its end-points have bits in
    % common, and output the corresponding bits where appropriate
    
    while (1) % we will break loop when interval reaches its final state
        
        if (hi < half) % lo < hi < 1/2 -> stretch interval and emit 0
            % 3) append a 0 followed by 'straddle' ones to the output
            % string. Reset the straddle counter to zero. The interval
            % re-scaling/stretching will be done after the if-statement.
            % 
            % ...
            % ...
            y=[y,0,ones(1,straddle)];
            straddle=0;
            
            
        elseif (lo >= half) % hi > lo >= 1/2 -> stretch and emit 1
            % 4) append a 1 followed by 'straddle' zeros to the output
            % string and reset the straddle counter
            % 
            % ...
            % ...
            y=[y,1,zeros(1,straddle)];
            straddle=0;

            % 5) take integer 'half' from lo and hi (the actual interval
            % re-stretching will follow after the if statement.
            % 
            % ...
            % ...
            hi=hi-half;
            lo=lo-half;

        elseif (lo >= quarter && hi < threequarters) % interval within [1/4,3/4] 
            % 6) take integer 'quarter' from lo and hi to prepare for a
            % centered re-stretch, and increase the 'straddle' counter by
            % one.
            % 
            % ...
            % ...
            % ...
            hi=hi-quarter;
            lo=lo-quarter;
            straddle = straddle + 1;
        else
            % the interval is now stretched to the point where it does not
            % have bits in agreement and we can break the endless loop
            break;
        end
        
        % 7) now multiply the interval end-points by 2 (the -1/2 or -1/4
        % operations have already been performed if appropriate, so the
        % interval is now in all cases within [0,1/2] and can simply be
        % multiplied by 2 to stretch to [0,1]. ADD 1 TO THE HI END-POINT
        % AFTER MULTIPLYING. THIS ENSURES THAT A 1 BIT IS PIPELINED INTO
        % THE HI BOUND AND WILL HELP AVOID UNDERFLOW/OVERFLOW.
        % 
        % ...
        % ...
        hi=2*hi+1;
        lo=2*lo;
    end    
end

% Add termination bits to the output string to ensure that the final
% dyadic interval lies within the source interval

straddle = straddle + 1;
if (lo < quarter)
    y = [y,0,ones(1,straddle)];
else
    y = [y,1,zeros(1,straddle)];
end

% THAT'S ALL FOLKS

        