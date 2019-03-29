clc;clear;clf;
set(gcf,'outerposition',get(0,'screensize'));
param=[2 6 5 3 4;%每次处理最多不超过的批次
       1 3 4 1 2];%每次处理所需要的时间
[~,n]=size(param);
eff=param(1,:)./param(2,:);
[mineff,neckindex]=min(eff);
plan=zeros(2,n);
%控制第一个流程的速度小于瓶颈速度即可，其他流程只要见到buffer区可以拉满，就拉满工作
plan(1,1)=lcm(param(1,1),param(1,neckindex));
plan(2,1)=plan(1,1)/mineff-plan(1,1)./param(1,1).*param(2,1);%每次停多久
buff=zeros(1,n-1);%一共需要n-1个缓冲区，假设每个缓冲区能放的容量为正无穷
counter=zeros(1,n);%累计每一处流程是否已经到了暂停的时间段
counttotal=zeros(1,n);
workstation_ui(n)=uicontrol;
workstation=zeros(2,n);%记录当前状态和剩余时间
workstation(1,1)=1;%第一个流程准备开始工作
workstation(2,1)=param(2,1);%第一个流程剩余的时间
buffer_ui(n-1)=uicontrol;
buffer=zeros(1,n-1);%记录当前缓冲区内的产品数量
for i=1:1:n%创建n个station的控件
    workstation_ui(i)=uicontrol('style','pushbutton','string',[num2str(i),' wait'],'fontsize',12,'position',[100+200*i,500,100,100]);
end
for i=1:1:n-1%创建n-1个buffer的控件
    buffer_ui(i)=uicontrol('style','pushbutton','string','0','fontsize',12,'position',[230+200*i,500,40,100]);
end
finish_ui=uicontrol('style','text','string','finishproduct:0','fontsize',18,'position',[500,300,300,40]);
finish=0;
clock_ui=uicontrol('style','text','string','time:0','fontsize',18,'position',[800,300,200,40]);
clock=0;
for time=1:1:10000
    for i=1:n%把迭代结果画出来
        if(workstation(1,i)==1)
            set(workstation_ui(i),'string',[num2str(i),' work',num2str(workstation(2,i))],...
                'BackgroundColor',[1 0 0]);
        else
            set(workstation_ui(i),'string',[num2str(i),' wait'],...
                'BackgroundColor',[0 1 0]);
        end
    end
    for i=1:n-1
        set(buffer_ui(i),'string',num2str(buffer(i)));
    end
    set(clock_ui,'string',['clock:',num2str(time)]);
    set(finish_ui,'string',['finishproduct:',num2str(finish)]);  
    if(workstation(1,1)==1)%忙碌状态
        workstation(2,1)=workstation(2,1)-1;
        if workstation(2,1)==0
            counttotal(1)=counttotal(1)+param(1,1);
            counter(1)=counter(1)+param(1,1);
            buffer(1)=buffer(1)+param(1,1);
            if plan(2,1)>0
                if(counter(1)<plan(1,1))
                    workstation(1,1)=1;
                    workstation(2,1)=param(2,1);
                else
                    workstation(1,1)=0;
                    workstation(2,1)=plan(2,1);
                    counter(1)=0;
                end
            else
                workstation(1,1)=1;
                workstation(2,1)=param(2,1);
            end
        end
    else%空闲状态
        workstation(2,1)=workstation(2,1)-1;
        if workstation(2,1)==0
            workstation(1,1)=1;
            workstation(2,1)=param(2,1);
        end
    end
    for worki=2:n-1%瓶颈到倒数第二个，只要buffer满了就可以送进去，做完就可以休息
        if workstation(1,worki)==0%状态为空闲
            if buffer(worki-1)>=param(1,worki)%缓冲区的料可以拉满
                workstation(1,worki)=1;
                workstation(2,worki)=param(2,worki);
                buffer(worki-1)=buffer(worki-1)-param(1,worki);
            end
        else%状态为工作
            workstation(2,worki)=workstation(2,worki)-1;
            if workstation(2,worki)==0
                counttotal(worki)=counttotal(worki)+param(1,worki);
                buffer(worki)=buffer(worki)+param(1,worki);
                if buffer(worki-1)>=param(1,worki)%缓冲区的料可以拉满
                    workstation(1,worki)=1;
                    workstation(2,worki)=param(2,worki);
                    buffer(worki-1)=buffer(worki-1)-param(1,worki);
                else
                    workstation(1,worki)=0;
                end                
            end
        end
    end
    if workstation(1,n)==0%最后一个状态为空闲
        if buffer(n-1)>=param(1,n)%缓冲区的料可以拉满
            workstation(1,n)=1;
            workstation(2,n)=param(2,n);
            buffer(n-1)=buffer(n-1)-param(1,n);
        end
    else%最后一个状态为工作
        workstation(2,n)=workstation(2,n)-1;
        if workstation(2,n)==0
            finish=finish+param(1,n);
            workstation(1,n)=0;
            if buffer(n-1)>=param(1,n)%缓冲区的料可以拉满
                workstation(1,n)=1;
                workstation(2,n)=param(2,n);
                buffer(n-1)=buffer(n-1)-param(1,n);
            else
                workstation(1,n)=0;
            end
        end
    end
    %pause;
end
