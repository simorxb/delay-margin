%% Design

% Define transfer function G
s = tf('s');
G = 1/(s^2 + 0.5*s + 1);

% Define controllers
C_V{1} = 4*(2*s+1)/(0.2*s+1);
C_V{2} = 14*(s+1)/(0.1*s+1);

for C_idx = 1:length(C_V)

    % Controller
    C = C_V{C_idx};

    % Loop function
    L = C * G;

    % Closed-loop transfer function
    T = feedback(L, 1);

    % Plot Bode diagram for L
    figure;
    bode(L);
    title(['Bode Diagram for L_' num2str(C_idx) ' = C_' num2str(C_idx) 'G']);
    grid on;

end

%% Simulation

% Define delays
delay_V = {0.01, 0.05, 0.075};

% Clear out_V
out_V = cell(length(C_V), length(delay_V));

% Cycle through controllers
for C_idx = 1:length(C_V)

    % Controller
    C = C_V{C_idx};
    
    % Cycle through delays
    for d_idx = 1:length(delay_V)

        % Delay
        delay = delay_V{d_idx};
        
        % Simulate
        out = sim("Delay_Margin.slx");
        
        % Store output data
        out_V{C_idx, d_idx} = out;
    
    end

end

%% Plot results

% Create figure
figure;

legend_V = cell(length(delay_V)+1, 1);

% Cycle through controllers
for C_idx = 1:length(C_V)

    % Subplot for controller
    subplot(length(C_V), 1, C_idx);

    % Get setpoint - always the same
    stp = out_V{C_idx, 1}.logsout.get('setpoint').Values.Data;
    t_stp = out_V{C_idx, 1}.logsout.get('setpoint').Values.Time;

    % Plot setpoint
    plot(t_stp, stp, '--', 'LineWidth', 2);
    hold on;
    
    % Setpoint legend
    legend_V{1} = 'Setpoint';
    
    % Cycle through delays
    for d_idx = 1:length(delay_V)
        
        % Get response data
        y = out_V{C_idx, d_idx}.logsout.get('y').Values.Data;
        t_y = out_V{C_idx, d_idx}.logsout.get('y').Values.Time;

        % Plot response
        plot(t_y, y, 'LineWidth', 2);
        
        % Response legend
        legend_V{d_idx + 1} = ['Response with delay = ' num2str(delay_V{d_idx}) 's'];

    end
    
    hold off;
    title(['Controller ' num2str(C_idx) ' performance']);
    xlabel('Time (s)');
    ylabel('Output');
    legend(legend_V, 'FontSize', 12);
    set(gca, 'FontSize', 12);
    grid on;

end