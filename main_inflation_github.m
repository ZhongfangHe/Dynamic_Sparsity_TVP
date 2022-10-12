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
rng(123456);


mdl = {'DTL', 'DTS', 'RMI','DHS','LMI'};
for mdlj = 1:1
    disp(mdl{mdlj});



    %% Read data to get y and x
    read_file = 'Inflation_Qtrly_Github.xlsx';
    read_sheet = 'Data2'; %change of inflation rate
    data = readmatrix(read_file, 'Sheet', read_sheet, 'Range', 'B3:V222');    
    [ng,nr] = size(data);
    inflation = data(:,1);
    reg = data(:,2:nr);    
    y = inflation(2:ng); %change
    uset = 1:(nr-1);
    x = [ones(ng-1,1) inflation(1:(ng-1)) reg(1:(ng-1),uset)]; %full
    
    
    %% Set the size of estimation/prediction sample
    [n,nx] = size(x);
    npred = 0;%41; %number of predictions >= 0
    nest = n - npred; %number of estimation data
    disp(['nobs = ', num2str(n), ', nx = ', num2str(nx)]);
    disp(['nest = ', num2str(nest), ', npred = ', num2str(npred)]); 
    
    
    %% Configuration
    ind_SV = 1; %if SV for measurement noise variance
    ind_sparse = 0; %if sparsifying is needed
    disp(['SV = ', num2str(ind_SV),', sparse = ', num2str(ind_sparse)]);    



    %% MCMC
    ndraws = 5000*10;
    burnin = 5000;
    disp(['burnin = ', num2str(burnin), ', ndraws = ', num2str(ndraws)]);

    tic;
    if npred == 0 %in-sample estimation only 
        ind_forecast = 0;   
        yest = y;
        xest = [ones(n,1)  normalize_data(x(:,2:nx))];
        switch mdlj
            case 1 %DTL
                draws = RWTVP_LS_RF(yest, xest, burnin, ndraws, ind_SV, ind_sparse, ind_forecast);
            case 2 %DTS
                draws = RWTVP_LS_SQ(yest, xest, burnin, ndraws, ind_SV, ind_sparse, ind_forecast);              
            case 3 %RMI
                MI_scenarios = [zeros(1,nx); [1 zeros(1,nx-1)]; ones(1,nx)];
                draws = RWTVP_RMI(yest, xest, burnin, ndraws, ind_SV, ind_sparse, ind_forecast, MI_scenarios);  
            case 4 %DHS
                draws = RWTVP_KHS3(yest, xest, burnin, ndraws, ind_SV, ind_forecast);
            case 5 %LMI
                draws = RWTVP_LS_LG(yest, xest, burnin, ndraws, ind_SV, ind_sparse, ind_forecast);           
            otherwise
                error('Wrong model');
        end
        disp([mdl{mdlj},' is completed!']);
        save(['Est_',mdl{mdlj},'_Inflation', '.mat'], 'draws');
        toc;
    else
        ind_forecast = 1;
        logpredlike = zeros(npred,1);
        valid_percent = zeros(npred,1); %count conditional likelihoods that are not NaN or Inf     
        for predi = 1:npred 
            % process data
            nesti = nest + predi - 1;
            yi = y(1:nesti,:);
            xi = x(1:nesti,:); %rescaling x is possible 
            
            yest = yi;
            xest = [ones(nesti,1)  normalize_data(xi(:,2:nx))];

            % estimate the model
            switch mdlj
                case 1 %DTL
                    draws = RWTVP_LS_RF(yest, xest, burnin, ndraws, ind_SV, ind_sparse, ind_forecast);
                case 2 %DTS
                    draws = RWTVP_LS_SQ(yest, xest, burnin, ndraws, ind_SV, ind_sparse, ind_forecast);                        
                case 3 %RMI
                    MI_scenarios = [zeros(1,nx); [1 zeros(1,nx-1)]; ones(1,nx)];
                    draws = RWTVP_RMI(yest, xest, burnin, ndraws, ind_SV, ind_sparse, ind_forecast, MI_scenarios);  
                case 4 %DHS
                    draws = RWTVP_KHS3(yest, xest, burnin, ndraws, ind_SV, ind_forecast);
                case 5 %LMI
                    draws = RWTVP_LS_LG(yest, xest, burnin, ndraws, ind_SV, ind_sparse, ind_forecast);                               
                otherwise
                    error('Wrong model');
            end
            
            % prediction
            xtp1 = x(nesti+1,:)'; 
            ytp1 = y(nesti+1);
            
            xmean = mean(xi(:,2:nx))';
            xstd = std(xi(:,2:nx))';
            xtp1_normalized = [1; (xtp1(2:nx) - xmean)./xstd];
            
            if mdlj == 3 %RMI
                [ytp1_pdf, ytp1_mean, ytp1_var, ytp1_pdf_vec, ind_valid] = pred_RMI(draws,...
                    xtp1_normalized, ytp1, ind_SV, MI_scenarios);
            elseif mdlj==4 %DHS 
                ind_KHS = 1;
                [ytp1_pdf, ytp1_mean, ytp1_var, ytp1_pdf_vec, ind_valid] = pred_TVP_HS(draws,...
                    xtp1_normalized, ytp1, ind_SV, ind_KHS);
            elseif mdlj == 5 %LMI
                [ytp1_pdf, ytp1_mean, ytp1_var, ytp1_pdf_vec, ind_valid] = pred_LS_LG(draws,...
                    xtp1_normalized, ytp1, ind_SV);
            elseif mdlj == 1 %DTL
                [ytp1_pdf, ytp1_mean, ytp1_var, ytp1_pdf_vec, ind_valid] = pred_LS_RF(draws,...
                    xtp1_normalized, ytp1, ind_SV);               
            else %DTS
                [ytp1_pdf, ytp1_mean, ytp1_var, ytp1_pdf_vec, ind_valid] = pred_LS_SQ(draws,...
                    xtp1_normalized, ytp1, ind_SV);
            end

            % store log likelihoods and prediction error
            logpredlike(predi,1) = log(ytp1_pdf(1))';
            valid_percent(predi,1) = sum(ind_valid(:,1))/ndraws;
           
            disp(['Prediction ', num2str(predi), ' out of ', num2str(npred), ' is finished!']);
            toc;   
            disp(' ');              
        end %end of prediction loop
        if predi == npred
            save(['Pred_',mdl{mdlj},'_Inflation.mat'],'draws','ytp1_pdf_vec','valid_percent');
        end
        
        write_column = {'C','D','E','F','G'};
        writematrix(logpredlike(:,1), read_file, 'Sheet', 'LPL',...
            'Range', [write_column{mdlj},'2']);       
    end %end of prediction choice
end %end of model loop













    




