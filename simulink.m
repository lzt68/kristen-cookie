clc;clear;clf;
set(gcf,'outerposition',get(0,'screensize'));
param=[2 6 5 3 4;%ÿ�δ�����಻����������
       1 3 4 1 2];%ÿ�δ�������Ҫ��ʱ��
[~,n]=size(param);
eff=param(1,:)./param(2,:);
[mineff,neckindex]=min(eff);
plan=zeros(2,n);
%���Ƶ�һ�����̵��ٶ�С��ƿ���ٶȼ��ɣ���������ֻҪ����buffer����������������������
plan(1,1)=lcm(param(1,1),param(1,neckindex));
plan(2,1)=plan(1,1)/mineff-plan(1,1)./param(1,1).*param(2,1);%ÿ��ͣ���
buff=zeros(1,n-1);%һ����Ҫn-1��������������ÿ���������ܷŵ�����Ϊ������
counter=zeros(1,n);%�ۼ�ÿһ�������Ƿ��Ѿ�������ͣ��ʱ���
counttotal=zeros(1,n);
workstation_ui(n)=uicontrol;
workstation=zeros(2,n);%��¼��ǰ״̬��ʣ��ʱ��
workstation(1,1)=1;%��һ������׼����ʼ����
workstation(2,1)=param(2,1);%��һ������ʣ���ʱ��
buffer_ui(n-1)=uicontrol;
buffer=zeros(1,n-1);%��¼��ǰ�������ڵĲ�Ʒ����
for i=1:1:n%����n��station�Ŀؼ�
    workstation_ui(i)=uicontrol('style','pushbutton','string',[num2str(i),' wait'],'fontsize',12,'position',[100+200*i,500,100,100]);
end
for i=1:1:n-1%����n-1��buffer�Ŀؼ�
    buffer_ui(i)=uicontrol('style','pushbutton','string','0','fontsize',12,'position',[230+200*i,500,40,100]);
end
finish_ui=uicontrol('style','text','string','finishproduct:0','fontsize',18,'position',[500,300,300,40]);
finish=0;
clock_ui=uicontrol('style','text','string','time:0','fontsize',18,'position',[800,300,200,40]);
clock=0;
for time=1:1:10000
    for i=1:n%�ѵ������������
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
    if(workstation(1,1)==1)%æµ״̬
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
    else%����״̬
        workstation(2,1)=workstation(2,1)-1;
        if workstation(2,1)==0
            workstation(1,1)=1;
            workstation(2,1)=param(2,1);
        end
    end
    for worki=2:n-1%ƿ���������ڶ�����ֻҪbuffer���˾Ϳ����ͽ�ȥ������Ϳ�����Ϣ
        if workstation(1,worki)==0%״̬Ϊ����
            if buffer(worki-1)>=param(1,worki)%���������Ͽ�������
                workstation(1,worki)=1;
                workstation(2,worki)=param(2,worki);
                buffer(worki-1)=buffer(worki-1)-param(1,worki);
            end
        else%״̬Ϊ����
            workstation(2,worki)=workstation(2,worki)-1;
            if workstation(2,worki)==0
                counttotal(worki)=counttotal(worki)+param(1,worki);
                buffer(worki)=buffer(worki)+param(1,worki);
                if buffer(worki-1)>=param(1,worki)%���������Ͽ�������
                    workstation(1,worki)=1;
                    workstation(2,worki)=param(2,worki);
                    buffer(worki-1)=buffer(worki-1)-param(1,worki);
                else
                    workstation(1,worki)=0;
                end                
            end
        end
    end
    if workstation(1,n)==0%���һ��״̬Ϊ����
        if buffer(n-1)>=param(1,n)%���������Ͽ�������
            workstation(1,n)=1;
            workstation(2,n)=param(2,n);
            buffer(n-1)=buffer(n-1)-param(1,n);
        end
    else%���һ��״̬Ϊ����
        workstation(2,n)=workstation(2,n)-1;
        if workstation(2,n)==0
            finish=finish+param(1,n);
            workstation(1,n)=0;
            if buffer(n-1)>=param(1,n)%���������Ͽ�������
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
