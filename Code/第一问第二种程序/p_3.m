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
    CNC_num=[];    down=[];    up=[];    location_all=[];
	CNC_order_state=[0,0,0,0,0,0,0,0];%用于记录CNCi正处理哪个序号的物料
    CNC_old=[0,0,0,0,0,0,0,0];
    CNC=[0,0,0,0,0,0,0,0];%0表示CNC未在加工
    CNC_worktime=[0,0,0,0,0,0,0,0];
    t_delta=0;
    time_all=0;
    location_current=1;%初始位置
    n=0;
    
    while(time_all<=8*3600)
        n=n+1;
        location_all(n)=location_current;%记录RGV运动位置
                
        %若都在工作,则等待最快完成的一个
        while(isempty(find(CNC==0)))
            a=max(CNC_worktime);
            t_delta=545-a;
            time_all=time_all+t_delta;
            CNC_worktime(find(CNC==1))=CNC_worktime(find(CNC==1))+t_delta;%更新其他正加工的CNC的已加工时间
            CNC(find(CNC_worktime>=545))=0;%加工完CNC置0
            CNC_worktime(find(CNC_worktime>=545))=0;%加工完CNC计时置0
        end
        
        while(1)%以概率搜索
            num=rem(round(rand()*10),8)+1;%取一个随机编号变异
            while(CNC(num)==1)
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
        time_all=time_all+t_move_choice(s+1)+t_delta;
        location_current=ceil(num/2);%更新当前位置
        CNC_worktime(find(CNC==1))=CNC_worktime(find(CNC==1))+t_move_choice(s+1)+t_delta;%更新其他正加工的CNC的已加工时间
        CNC(num)=1;%更新CNC状态
               
        CNC(find(CNC_worktime>=545))=0;%加工完CNC置0
        CNC_worktime(find(CNC_worktime>=545))=0;%加工完CNC计时置0
        
        time_all=time_all+t_wash;
        CNC_worktime(find(CNC==1))=CNC_worktime(find(CNC==1))+t_wash;%更新其他正加工的CNC的已加工时间
        
        CNC(find(CNC_worktime>=545))=0;%加工完CNC置0
        CNC_worktime(find(CNC_worktime>=545))=0;%加工完CNC计时置0
        
        
        up(n+1)=time_all-t_delta-t_wash;%记录上料时间
        if(CNC_order_state(num)~=0)
            down(CNC_order_state(num))=time_all-t_delta-t_wash;%记录下料时间
        end
        
        CNC_num(n)=num;%记录CNC编号次序
        CNC_order_state(num)=n;
    end
    m=m+1;
    location_save{m}=location_all(1,:);%保存每一次的路径
    down_save{m}=down(1,:);
    up_save{m}=up(1,:);
    CNC_num_save{m}=CNC_num(1,:);
    task_num(m,:)=n;
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