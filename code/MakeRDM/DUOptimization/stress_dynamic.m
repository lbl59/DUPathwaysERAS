% Scenario-Tunable Regional Synthetic Streamflow (STRESS) Generator
function [Qs, Es] = stress_dynamic(Random_Matrix, Q_historical, E_historical, num_years, rdm)
    
    mu_sinusoid = @(A, T, p, i, n) 1. + A * sin(2.*pi*(i:52:n)/T + p) - A * sin(p);
    num_years = num_years + 1; % adjusts for the new corr technique
    weekly_mean = zeros(52, 1);
    weekly_stdev = zeros(52, 1);
    QEinput = {Q_historical, E_historical};

    for m = 1:2 % evaporation or demand
    	npoints = length(QEinput{m});
    	for k = 1:npoints % k is the location index (e.g. Falls Lake, Jordan Lake, etc.)
    	    nQE_historical = length(QEinput{m}{k}(:,1));
            Qsk = -ones(num_years-1, 52)*100;
            Q_matrix_int = QEinput{m}{k};

            if size(Q_matrix_int)(1) > 2 % if matrix exists (i.e. if evaporations series exists, since all locations have inflow series)
    		nQ = nQE_historical * 100;

                Z = zeros(nQ, 52);
                logQint = log(Q_matrix_int);
                logQ = repmat(logQint, 100, 1);

                weekly_mean = mean(logQint);
                weekly_stdev = std(logQint);
                for i=1:52
                    Z(:, i) = (logQ(:, i) - weekly_mean(i)) / weekly_stdev(i);
                    Qs_uncorr(:, i) = Z(Random_Matrix(:, i), i);
                end

                Z_vector = reshape(Z', 1, []);
                Z_shifted = reshape(Z_vector(27:(nQ * 52 - 26)), 52, [])';

                % The correlation matrices should use the historical Z's
                % (the "appended years" do not preserve correlation)
                U =         chol(corr(Z        (1:nQE_historical,     :)));
                U_shifted = chol(corr(Z_shifted(1:nQE_historical - 1, :)));


                Qs_uncorr_vector = reshape(Qs_uncorr(:,:)',1,[]);
                reshape(Qs_uncorr_vector(27:(num_years*52-26)),52,[])';

                Qs_uncorr_shifted(:,:) = reshape(Qs_uncorr_vector(27:(num_years*52-26)),52,[])';

                Qs_corr(:,:) = Qs_uncorr(:,:)*U;
                Qs_corr_shifted(:,:) = Qs_uncorr_shifted(:,:)*U_shifted;
                

                Qs_log(:,1:26) = Qs_corr_shifted(:,27:52);
                Qs_log(:,27:52) = Qs_corr(2:num_years, 27:52);

                for i=1:52
                    mu_rdm_multiplier = mu_sinusoid(rdm(1), rdm(2), rdm(3), i, (num_years-1)*52)'; % reapplied Aug 2021
                    %mu_rdm_multiplier = 1; % don't apply adjustment here
                    Qsk(:,i) = exp(Qs_log(:, i)*weekly_stdev(i) + weekly_mean(i) * mu_rdm_multiplier);
                end
            end

            if m == 1
                Qs{k} = Qsk;
            else
                Es{k} = Qsk;
            end
        end
    end
end
