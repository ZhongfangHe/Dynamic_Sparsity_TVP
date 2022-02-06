% Simulate data

clear;
rng(12345678);


%% Simulate
nrep = 1;
n = 300;
K = 6;
for j = 1:nrep
    % generate x
    x = randn(n,K);

    % generate beta
    btrue = zeros(n,K);
    if K > 1
        btrue(:,1) = cumsum(0.1*randn(n,1)); %DGP1: RW
        
        bp = [round(n/3)  round(2*n/3)];
        btrue(bp(1):bp(2),2) = 1;
        btrue(bp(2)+1:n,2) = 0.5; %DGP2: chang point        
        
        
        bp = [round(n/3)  round(2*n/3)];
        bx = (bp(1):bp(2))';
        btrue(bp(1):bp(2),3) = (bx - bp(1))/(bp(2)-bp(1));
        btrue(bp(2)+1:n,3) = 1; %DGP 3: mixture linear
        
        bp = [round(n/3)  round(2*n/3)];
        btrue(bp(1):bp(2),4) = cumsum(0.1 * randn(bp(2)-bp(1)+1,1));
        btrue(bp(2)+1:n,4) = 1; %DGP 4: mixture RW
        
        btrue(:,5) = ones(n,1); %DGP5: ones
    else
        bp = [round(n/3)  round(2*n/3)];
        btrue(bp(1):bp(2)) = 1;
        btrue(bp(2)+1:n) = -1;
    end
    
    % determine noise level
    noise_level = {'ML','MM','MS'};
    rsquare = [0.2  0.5  0.8];
    nr = length(rsquare);
    s = 1./rsquare - 1;
    yfit = sum(btrue .* x, 2);
    sig2true = s * var(yfit);
    sigtrue = sqrt(sig2true);

    % generate y with different noise level, write output
    for rj = 1:nr
        y = yfit + sigtrue(rj) * randn(n,1);

        write_file = ['Simulated_Data_', noise_level{rj}, '.xlsx'];
        write_sheet = ['D',num2str(j)];
        title = cell(1,2*K+1);
        title{1} = ['y(sig=',num2str(sigtrue(rj)) ,')'];
        for jj = 1:K
            title{jj+1} = ['x',num2str(jj)];
            switch jj
                case 1
                    title{K+1+jj} = 'RW';
                case 2
                    title{K+1+jj} = 'CP';
                case 3
                    title{K+1+jj} = 'Mix_LN';
                case 4
                    title{K+1+jj} = 'Mix_RW';
                case 5
                    title{K+1+jj} = 'One';                    
                otherwise
                    title{K+1+jj} = 'Zero';
            end
        end
        writecell(title, write_file, 'Sheet', write_sheet, 'Range', 'A1');
        writematrix([y x btrue], write_file, 'Sheet', write_sheet, 'Range', 'A2');
    end
end

