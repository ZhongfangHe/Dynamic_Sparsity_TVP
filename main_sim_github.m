% Estimate a RW-TVP model:
% yt = xt' * bt + N(0,sig2t), 
% b_jt = b_{j,t-1} + vj * N(0,d_jt), j = 1, ..., K
% d_jt = f(z_jt),
% z_jt = z_{j,t-1} + N(0,sj),
%
% use GCK algorithm for zt (adpative MH， multivariate)
% draw b0, v, s by integrating out bt (adaptive MH, multivariate)
% z0 is integrated out and is not sampled
% use ASIS for extra boosting


clear;
dbstop if warning;
dbstop if error;
rng(12345);


%% Read data
mdl = {'LS_RF','LS_SQ'};
noise_level = {'S','M','L'};
n_sheet = 1;

tic;
for mdlj = 1:2
    disp(mdl{mdlj});
    
    for ni = 1:1
    disp(noise_level{ni});

        for sheet_i = 1:1
            disp(['work sheet ', num2str(sheet_i)]);
            
            read_file = ['Simulated_Data_M', noise_level{ni}, '.xlsx'];
            read_sheet = ['D',num2str(sheet_i)];
            data = readmatrix(read_file, 'Sheet', read_sheet, 'Range', 'A2:M301');
            y = data(:,1);
            x = data(:,2:7);
            btrue = data(:,8:13);


            % Set up
            ndraws = 5000*10;
            burnin = 5000*1;

            ind_SV = 0;
            ind_forecast = 0;
            ind_sparse = 0;
            switch mdlj
                case 1 %truncated linear
                    draws = RWTVP_LS_RF(y, x, burnin, ndraws, ind_SV, ind_sparse, ind_forecast);                                       
                case 2 %truncated square
                    draws = RWTVP_LS_SQ(y, x, burnin, ndraws, ind_SV, ind_sparse, ind_forecast);
                otherwise
                    error('Wrong model');
            end
            disp([mdl{mdlj},', ',noise_level{ni},', Sheet ', num2str(sheet_i), ' is completed!']);
            toc;
            if sheet_i == 1
                save(['Est_',mdl{mdlj},'_M', noise_level{ni}, '.mat'], 'draws');
            end

            
            % RMSE
            if sheet_i == 1
                rmse = compute_rmse_tvp_beta(draws.beta, btrue);
                write_col = {'A','B','C','D','E','F','G'};
                K = size(x,2);
                for j = 1:K
                    write_sheet = ['Para',num2str(j)];
                    writematrix(rmse(:,j),read_file,'Sheet',write_sheet,'Range',[write_col{mdlj}, '2']);
                end
            end
            
        end %loop of sheet
    end %loop of noise level
end %loop of model













    





