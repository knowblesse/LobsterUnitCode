function [ recoveredLocData ] = recoverLocData( originalLocData )
% tracking loss로 인한 데이터 손실 부분을 주변 데이터를 토대로 추측해서 재구성.
    % 현재 살펴본 바에 따르면 tracking이 끊기는 경우 X 데이터는 -1, Y 데이터는 481의 값을 취하게 된다.
    % 이러한 값이 중간에 등장하게 되면 그 전후 데이터를 토대로 추측해서 loss가 생긴 부분을 보간한 데이터를 출력한다.
    % 끊긴 부분 양 옆의 데이터의 차이가 크면 에러를 출력한다.
    % @Knowblesse 2017
    
    % argument :
    % originalLocData cell(2,1);
    
    
    %% CONSTANTS 
    % 정상적인 데이터의 범위를 지정해 준다.
    X_RANGE = [200,600];
    Y_RANGE = [100,400];
    
    %% Check Data Format
    type = whos('originalLocData');
    
    if ~strcmp(type.class, 'cell') && isequal(type.size,[2,2])
        error('Wrong type argument');
    end
    
    %% Check Loss point
    dataLength = size(originalLocData{1},1); % 원본 데이터의 크기
    points_1 = [];
    points_2 = [];
    
    wrongFlag_1 = false;
    wrongFlag_2 = false;
    
    for i = 1 : dataLength % 모든 데이터에 대해서
        % Loss point 1 ( 빨간색 XY )
        if ~and(X_RANGE(1)<originalLocData{1}(i),originalLocData{1}(i) < X_RANGE(2))
            % X 좌표가 WRONG_X_LOW 보다 작고, (Y 좌표가 WRONG_Y_MAX 보다 크거나 0인 경우)
            % 대부분의 경우 X 좌표가 -1이고 Y 좌표가 481인 경우가 튕긴 상태인데, 가끔 Y 좌표가 0인 경우가
            % 나옴. 이 경우를 뽑기 위해서 X는 무지 작고 AND Y는 0 혹은 큰 값인 경우를 감지함.
            if wrongFlag_1 == false
                wrongFlag_1 = true;
                points_1 = [points_1;[i,0]];
            end
        % No Loss Point 1
        else
            if wrongFlag_1 == true
                wrongFlag_1 = false;
                points_1(end,2) = i-1;
            end
        end
        % Loss point 2 ( 초록색 XY )
        if ~and(X_RANGE(1)<originalLocData{3}(i),originalLocData{3}(i) < X_RANGE(2))
            if wrongFlag_2 == false
                wrongFlag_2 = true;
                points_2 = [points_2;[i,0]];
            end
        % No Loss Point 2
        else
            if wrongFlag_2 == true
                wrongFlag_2 = false;
                points_2(end,2) = i-1;
            end
        end
    end
    
    
    % 초반에 tracking이 안되고 있는 지점의 데이터는 처음으로 tracking이 된 시점으로 대체
    recoveredLocData = originalLocData;
    recoveredLocData{1}(1:points_1(1,2)) = recoveredLocData{1}(points_1(1,2)+1); 
    recoveredLocData{2}(1:points_1(1,2)) = recoveredLocData{2}(points_1(1,2)+1); 
    recoveredLocData{3}(1:points_2(1,2)) = recoveredLocData{3}(points_2(1,2)+1); 
    recoveredLocData{4}(1:points_2(1,2)) = recoveredLocData{4}(points_2(1,2)+1); 
    warning(['빨간 LED의 처음 ',num2str(points_1(1,2)), ' 개의 포인트를 tracking하지 못하였습니다.']);
    warning(['초록 LED의 처음 ',num2str(points_2(1,2)), ' 개의 처음 포인트를 tracking하지 못하였습니다.']);
    
    points_1(1,:) = [];
    points_2(1,:) = [];
    
    %% Compensation
    %TODO 나중에는 양 끝단의 값의 평균으로 다 집어쳐넣는게 아니라 interp1 함수로 보간시키는 방식이 좋을 듯
    for i = 1 : size(points_1,1)-1 % Red LED tracking 놓친 것을 복구시켜줌
        if abs(points_1(i,2) - points_1(i,1)) > 100
            warning(['tracking이 장기간 끊긴적이있음.  index : ', num2str(abs(points_1(i,1) - points_1(i,2))), ' points']);
        end
        for l = 1 : 2
            compensateData = originalLocData{l}(points_1(i,1)-1) + round((originalLocData{l}(points_1(i,2)+1) - originalLocData{l}(points_1(i,1)-1)) / 2 );
            recoveredLocData{l}(points_1(i,1):points_1(i,2)) = compensateData;
        end
    end
    for i = 1 : size(points_2,1)-1 % Green LED tracking 놓친 것을 복구시켜줌 맨 마지막꺼는 
        if abs(points_2(i,2) - points_2(i,1)) > 100
            warning(['tracking이 장기간 끊긴적이있음.  index : ', num2str(abs(points_2(i,1) - points_2(i,2))), ' points']);
        end
        for l = 3 : 4
            compensateData = originalLocData{l}(points_2(i,1)-1) + round((originalLocData{l}(points_2(i,2)+1) - originalLocData{l}(points_2(i,1)-1)) / 2 );
            recoveredLocData{l}(points_2(i,1):points_2(i,2)) = compensateData;
        end
    end
    % points 에 찍힌 마지막 데이터 부분은 끝에 날라간 부분이므로, 날라가기 직전의 값으로 덮어준다.
    recoveredLocData{1}(points_1(end,1):end) = recoveredLocData{1}(points_1(end,1)-1);
    recoveredLocData{2}(points_1(end,1):end) = recoveredLocData{2}(points_1(end,1)-1);
    recoveredLocData{3}(points_2(end,1):end) = recoveredLocData{3}(points_2(end,1)-1);
    recoveredLocData{4}(points_2(end,1):end) = recoveredLocData{4}(points_2(end,1)-1);
end

