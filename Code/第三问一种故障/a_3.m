%第三问
clc;clear;
tic;
t_move_choice=[0,18,32,46];%移动i个单位所需时间
t_process_1= 545;%CNC加工完成一个一道工序的物料所需时间
t_odd=27;%RGV为CNC1#，3#，5#，7#一次上下料所需时间
t_even=32;%RGV为CNC2#，4#，6#，8#一次上下料所需时间
t_wash=25;%RGV完成一个物料的清洗作业所需时间
t_task_odd=t_odd;
t_task_even=t_even;
m=0;

while(m<5000)
    CNC_num=[];    down=[];    up=[];    location_all=[]; failure_task=[];
	CNC_order_state=[0,0,0,0,0,0,0,0];%用于记录CNCi正处理哪个序号的物料
    CNC=[0,0,0,0,0,0,0,0];%0表示CNC未在加工
    CNC_worktime=[0,0,0,0,0,0,0,0];
    
    CNC_failuretime=zeros(1,8);%故障计时
    CNC_repairtime=zeros(1,8);%下一次故障时修复好的时间
    
    %产生下一次故障时修复好的时间，在600-1200之间
    for i=1:8
        CNC_repairtime(i)=600+round((1200-600)*rand());
    end
    
    t_delta=0;
    time_all=0;
    location_current=1;%初始位置
    
    n=0;
    failure_num=0;%故障次数
    
    while(time_all<=8*3600)
        n=n+1;
        location_all(n)=location_current;%记录RGV运动位置

        %若都在工作或故障,则等待最快完成的一个
        while(isempty(find(CNC==0)))
            a=max(CNC_worktime);
            t_delta_1=545-a;
            
            a=max(CNC_failuretime);
            if(a>0)
                t_delta_2=CNC_repairtime(find(CNC_failuretime==a))-a;
            else
                t_delta_2=1e+4;
            end
            
            t_delta=min(t_delta_1,t_delta_2);
            
            time_all=time_all+t_delta;
            
            CNC_worktime(find(CNC==1))=CNC_worktime(find(CNC==1))+t_delta;%更新其他正加工的CNC的已加工时间
            CNC(find(CNC_worktime>=545))=0;%加工完CNC置0
            CNC_worktime(find(CNC_worktime>=545))=0;%加工完CNC计时置0
            
            CNC_failuretime(find(CNC==2))=CNC_failuretime(find(CNC==2))+t_delta;%更新其他正故障的CNC的已故障时间
            index=find(CNC_failuretime>=CNC_repairtime);
            if(~isempty(index))%修理完重新生成下一次的故障修理时间
                CNC(index)=0;%修理完CNC置0
                CNC_failuretime(index)=0;%修理完CNC置0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime(index(p))=600+round((1200-600)*rand());
                end
            end
            index=[];
        end
        
        while(1)%以概率搜索
            num=rem(round(rand()*10),8)+1;%取一个随机编号变异
            while(CNC(num)==1||CNC(num)==2)%若目标在工作或故障，则更换目标
                num=rem(round(rand()*10),8)+1;%取一个随机编号变异
            end
            s=abs(location_current-ceil(num/2));%与目标CNC的距离
            if(s==0)
                break;
            end
            if(s==1)
                if(rand()<1/2)
%                 if(rand()<0.6)
                    break;
                end
            end
            if(s==2)
                if(rand()<1/3)
%                 if(rand()<0.3)
                    break;
                end
            end
            if(s==3)
                if(rand()<1/6)
%                 if(rand()<0.1)
                    break;
                end
            end
        end
                             
        %判断奇偶
        if(mod(num,2))
            t_delta=t_task_odd;
        else
            t_delta=t_task_even;
        end
        
        location_current=ceil(num/2);%更新当前位置
        
        %发生故障,以0.01的概率，放弃当前任务
        if(round(99*rand())==0)
            CNC(num)=2;
            failure_num=failure_num+1;
            failure_task(failure_num,1)=n;%记录故障的物料序号
            failure_task(failure_num,2)=num;%记录故障的CNC
            failure_task(failure_num,3)=time_all+t_move_choice(s+1)+t_delta;%记录CNC故障的开始时间
            failure_task(failure_num,4)=time_all+t_move_choice(s+1)+t_delta+CNC_repairtime(num);%记录CNC故障的结束时间
        end
        
        time_all=time_all+t_move_choice(s+1)+t_delta;
        CNC_worktime(find(CNC==1))=CNC_worktime(find(CNC==1))+t_move_choice(s+1)+t_delta;%更新其他正加工的CNC的已加工时间
        
        if(CNC(num)==0)
            CNC(num)=1;%更新CNC状态
        end
        
        CNC(find(CNC_worktime>=545))=0;%加工完CNC置0
        CNC_worktime(find(CNC_worktime>=545))=0;%加工完CNC计时置0
        
        CNC_failuretime(find(CNC==2))=CNC_failuretime(find(CNC==2))+t_move_choice(s+1)+t_delta;%更新其他正故障的CNC的已故障时间
        index=find(CNC_failuretime>=CNC_repairtime);
        if(~isempty(index))%修理完重新生成下一次的故障修理时间
            CNC(index)=0;%修理完CNC置0
            CNC_failuretime(index)=0;%修理完CNC置0
            [o,p]=size(index);
            for i=1:p
                CNC_repairtime(index(p))=600+round((1200-600)*rand());
            end
        end
        index=[];
        
        
        time_all=time_all+t_wash;
        CNC_worktime(find(CNC==1))=CNC_worktime(find(CNC==1))+t_wash;%更新其他正加工的CNC的已加工时间
        
        CNC(find(CNC_worktime>=545))=0;%加工完CNC置0
        CNC_worktime(find(CNC_worktime>=545))=0;%加工完CNC计时置0
        
        CNC_failuretime(find(CNC==2))=CNC_failuretime(find(CNC==2))+t_wash;%更新其他正故障的CNC的已故障时间
        index=find(CNC_failuretime>=CNC_repairtime);
        if(~isempty(index))%修理完重新生成下一次的故障修理时间
            CNC(index)=0;%修理完CNC置0
            CNC_failuretime(index)=0;%修理完CNC置0
            [o,p]=size(index);
            for i=1:p
                CNC_repairtime(index(p))=600+round((1200-600)*rand());
            end
        end
        index=[];
        
        
        up(n+1)=time_all-t_delta-t_wash;%记录上料时间
        if(CNC_order_state(num)~=0)
            down(CNC_order_state(num))=time_all-t_delta-t_wash;%记录下料时间
        end
        
        CNC_num(n)=num;%记录CNC编号次序
        if(CNC(num)==2)
            CNC_order_state(num)=0;
        else
            CNC_order_state(num)=n;
        end
    end
    m=m+1;
    location_save{m}=location_all(1,:);%保存每一次的路径
    down_save{m}=down(1,:);%保存每一次的下料时间
    up_save{m}=up(1,:);%保存每一次的上料时间
    CNC_num_save{m}=CNC_num(1,:);%保存每一次的CNC加工编号序列
    task_num(m,:)=n;%保存每一次的完成物料数
    failure_num_save(m,:)=failure_num;%保存每一次的故障次数
    failure_task_save{m}=failure_task;%保存每一次的故障记录
end
max(task_num)
find(task_num==max(task_num))
% filetitle='C:\Users\Arthur\Documents\MATLAB\国赛\result.xlsx';
% %存储的excel的位置和名称
% for i=1:m
%     if isempty(location_save{i})
%     continue;
%     else
%         xlrange=['A',num2str(i)];
%         %存储表格中的位置,一次存一行
%         xlswrite(filetitle,location_save{i},'sheet1',xlrange);
%         %存储每组数据
%     end
% end
toc;