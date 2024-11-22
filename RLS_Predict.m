rls = rlsdata(8600:28600, :);
RLS_Predict1(rls)
function RLS_Predict1(rls)
    % 初始化参数
    n = 4;        % 参数数量 a, b, c, d
    delta = 1000; % 初始化逆协方差矩阵的常数
    P = delta * eye(n); % 逆协方差矩阵
    h = zeros(n,1); % 参数向量 [a; b; c; d]
    lambda = 0.6;     % 遗忘因子，取值范围 (0,1]
    
    % 存储参数历史以便绘图
    h_history = [];
    y_hat_history = []; % 存储预测的 y 值
    y_history = [];     % 存储实际的 y 值

    % 从 rls 变量中读取数据
    % 假设 rls(:,1) 是 x1，rls(:,2) 是 x2，rls(:,3) 是 y
    x1_data = rls(:,1)/1000;
    x2_data = rls(:,2)/1000;
    y_data = rls(:,3);

    % 数据点数量
    num_points = length(x1_data);

    for i = 1:num_points
        % 实时获取输入数据
        x1 = x1_data(i);
        x2 = x2_data(i);
        y = y_data(i);

        % 构建输入向量
        z1 = x1 * x2;%
        z2 = abs(x2)^2;%
        z3 = x1^2;%力矩的平方
        x = [z1; z2; z3; 1];

        % 计算增益向量 K
        K = P * x / (lambda + x' * P * x);

        % 预测输出
        y_hat = h' * x;

        % 计算误差
        e = y - y_hat;

        % 更新参数向量 h
        h = h + K * e;

        % 更新逆协方差矩阵 P
        P = (P - K * x' * P) / lambda;

        % 记录参数和预测值
        h_history = [h_history, h];
        y_hat_history = [y_hat_history; y_hat];
        y_history = [y_history; y];

        % 显示当前结果
        fprintf('第 %d 次迭代:\n', i);
        fprintf('预测 y = %.4f\n', y_hat);
        fprintf('实际 y = %.4f\n', y);
        fprintf('更新的参数: a = %.4f, b = %.4f, c = %.4f, d = %.4f\n\n', h(1), h(2), h(3), h(4));
    end

    % 绘制参数收敛曲线
    figure;
    subplot(4,1,1);
    plot(h_history(1,:), 'r', 'LineWidth', 1.5);
    ylabel('参数 a');
    grid on;

    subplot(4,1,2);
    plot(h_history(2,:), 'g', 'LineWidth', 1.5);
    ylabel('参数 b');
    grid on;

    subplot(4,1,3);
    plot(h_history(3,:), 'b', 'LineWidth', 1.5);
    ylabel('参数 c');
    grid on;

    subplot(4,1,4);
    plot(h_history(4,:), 'k', 'LineWidth', 1.5);
    ylabel('参数 d');
    xlabel('迭代次数');
    grid on;

    % 绘制预测值和实际值的对比曲线
    figure;
    plot(y_history, 'b', 'LineWidth', 1.5);
    hold on;
    plot(y_hat_history, 'r--', 'LineWidth', 1.5);
    xlabel('样本点');
    ylabel('输出值');
    legend('实际值 y', '预测值 y\_hat');
    title('预测值与实际值对比');
    grid on;
end