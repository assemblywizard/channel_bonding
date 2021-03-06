function [T channel_lexic allocations oldT olda] = throughput(N,C,widths)
% [T channel_lexic allocations] = throughput(N,C)
if nargin  == 2
    widths = 2.^([0:3]);
end
    channel_lexic = create_channel(widths);
    
    ww = [0 widths];
    for w=1:numel(ww)
        indw(ww(w)+1) = w;
        TT(w) = BSSThroughput(ww(w));
    end
    
% allh = nextstring_fast(max_element,N);
% allocations = combinator(int8(max_element),N); %change ** TODO with nextcomb or nextchoose


    text1 = 'Computing Throughput: ';
    ll = numel(text1);
    text2 = '';
    for ki=1:ll
    text2=[text2 '\b'];
    end

    text2 = [text2 '\b\b\b\b\b\b'];
    out = [text2 text1 '%2.2f%%'];

    check_every=10000;



    
    
% combs = combinator(numel(channel_lexic),2,'c');
% 
% ccc = eye(numel(channel_lexic),numel(channel_lexic));
% ccc(1,1) = 0;
% for iiip=1:size(combs,1)
%     ip = combs(iiip,:);
%     ccc(ip(1),ip(2)) = ~isempty(fastintersect(channel_lexic(ip(1)).index, channel_lexic(ip(2)).index) ); % we can speed up intersect
%     ccc(ip(2),ip(1)) = ccc(ip(1),ip(2));
% end
% This is speeded up by the following

nnn = numel(channel_lexic);
ccc = eye(nnn,nnn);
ccc(1,1) = 0;
for ii=2:nnn
ccc(ii,:) = cellfun(@afun,repmat({channel_lexic(ii).index},1,nnn),{channel_lexic.index});
end

    function out = afun(A,B)
    % a and b must be sorted!
%         out = ~isempty(a(ismembc(a,b)));
        if ~isempty(A)&&~isempty(B)
            P = zeros(1, max(max(A),max(B)) ) ;
            P(A) = 1;
            out = ~isempty(B(logical(P(B))));
        else
            out = false;
        end
    end

%     function C = fastintersect(A,B)
%         % works only on integers!
%         if ~isempty(A)&&~isempty(B)
%             P = zeros(1, max(max(A),max(B)) ) ;
%             P(A) = 1;
%             C = B(logical(P(B)));
%         else
%             C = [];
%         end
%     end

T = zeros(N,1);
count = 0;

CNT = 1;
allocation = ones(1,N);

mmm = max_element^N;
for iii = 1:mmm
% if rem(iii,check_every) == 0
%     fprintf(1,out,(100*iii/mmm))
% end
    count = count + 1;
%     allocation = allh();

    allocations(:,count) = allocation;
    N_Ov = zeros(N,N);
    for BSS = 1:N
        for j=BSS+1:N
                N_Ov(BSS,j) =  ccc(allocation(BSS),allocation(j));
                %~isempty(intersect(channel_lexic(allocation(BSS)).index,channel_lexic(allocation(j)).index  )); %sum one if they overlap
                N_Ov(j,BSS) = N_Ov(BSS,j);
        end
          if  any(N_Ov(BSS,:)) %can use sum(N_Ov(BSS,:))
            tempT(BSS) = 0;
            %T(BSS, count) = 0;
          else
              %disp (channel_lexic(allocations(allocation,BSS)).width)
%               disp(channel_lexic(allocations(allocation,BSS)).index)
              %T(BSS,count) = BSSThroughput(channel_lexic(allocation(BSS)).width);
              tempT(BSS) = TT(indw(channel_lexic(allocation(BSS)).width +1 ) );
              %BSSThroughput(channel_lexic(allocation(BSS)).width);
          end
    end
    flag = false;
    if ~any(any(all(bsxfun(@eq,tempT',T)))) %~ismember(tempT,T','rows')
%     for iiii = 1:count-2
%         if isequal(tempT(:),T(:,iiii))
%             flag = true;
%             break;
%         end
%     end
%     if ~flag
        T(:,count) = tempT;
    else
        count = count - 1;
    end
    
    if CNT < mmm
        if allocation(N) == max_element  % This col is as high as it can go.
                cnt = N-1; % Look for first col to update.

                while allocation(cnt) == max_element
                    cnt = cnt-1;  % Keep looking for first col to update.
                end

                allocation(cnt) = allocation(cnt) + 1; % Increase this col.
                allocation((cnt+1):N) = 1; % And set the followers to 1.
        else
                allocation(N) = allocation(N) + 1; % This col is not done yet,
        end

            CNT = CNT + 1;   
    end
end


[qq,ii,~] = unique(T','rows','first');
T = qq';
allocations = allocations(:,ii);

if nargout > 4
olda = allocations';
oldT = T;
end


toremove = find(all(bsxfun(@eq,T,zeros(N,1))));
allocations(:,toremove) = [];
T(:,toremove) = [];

allocations = allocations';

    function channel_lexic = create_channel(varargin)
        if nargin < 1
            widths = 2.^([0:3]);
        else
            widths = varargin{1};
        end
    max_element = 1; %fix this 2^C
    channel_lexic = set_struct('channel_lexic','width',zeros(1,max_element));
    channel_lexic(max_element).index = [];
    channel(C).index = -1;
    channel(C).number = -1;
    element = 1;
    for width = widths
        channel(width).index = generate_continguous(width);
        channel(width).number = size(channel(width).index,1);
        for jip = 1:channel(width).number
            element = element + 1;
            channel_lexic(element).index = channel(width).index(jip,:);
            channel_lexic(element).width = width;
        end
    end
    
        function out = generate_continguous(width)
            %generate contiguous combinations given a certain width
            for i=1:C-width+1
                out(i,:) = i:i+width-1;
            end
        end
        
%         disp('to fix')
%     disp(numel(channel_lexic))
%         i = 1;
%     while i < numel(channel_lexic) %REMOVE NON CONTIGUOUS
%         if  ((max(diff(channel_lexic(i).index)) > 1) | (isempty(channel_lexic(i).index)) )
%           %  disp([ 'removed' num2str(channel_lexic(i).index)])
%             channel_lexic(i) = [];
%         else
%             i = i+1;
%         end
%     end
% disp('done')
    max_element = numel(channel_lexic);
    end

    function S=BSSThroughput(W)
    % N_Ov how many  stations on same channel
%     if N_Ov > 1
%         S = 0;
%         return
%     end
        if W == 0
            S= 0;
            return
        end
    M=1;
    L=12000;
    A=1;

    Ts=Ts80211ac(M,L,A,3/4,6,W*52,M,1);

    SLOT = 9E-6;   

    S=L/(15.5*SLOT+Ts);




    function TxD = Ts80211ac(s,L,N,Coding,Mod,subcarriers,M,Ng)

    SIFS = 16E-6;
    DIFS = 34E-6;
    SLOT = 9E-6;  
    Ts=4E-6;

	PHY_h_MU=    8E-6 + 8E-6 + 4E-6 + 8E-6 + 4E-6 + M*4E-6 + 4E-6;
	PHY_h=       8E-6 + 8E-6 + 4E-6 + 8E-6 + 4E-6 + 4E-6 + 4E-6;

%	CSI_feedback = ceil(16*M*234/Ng);
    CSI_feedback = 0;
	MU_RTS = 20*8+(M-1)*6*8;
	MU_CTS = 14*8+CSI_feedback; 
	
	MAC_h=36*8;
	FCS=4*8;

	MPDU_Del=4*8;
	BACK=32*8; 

	MPDU=MAC_h+L+FCS;

	ServiceField=16; 
	Tail_bits=6;

	PSDU = -1;


	if(N==1) PSDU = ServiceField + MPDU + Tail_bits;
	else PSDU = ServiceField + N*(MPDU_Del+MPDU) + Tail_bits;
    end
        
	TxPSDU = PHY_h_MU+ceil(PSDU/(subcarriers*Mod*Coding))*Ts;

	PSDU_RTS = ServiceField + MU_RTS +Tail_bits;
	PSDU_CTS = ServiceField + MU_CTS +Tail_bits;
	PSDU_BAK = ServiceField + BACK +Tail_bits;

	TxRTS = PHY_h_MU+ceil(PSDU_RTS/(subcarriers*Mod*Coding))*Ts;
	TxCTS = PHY_h+ceil(PSDU_CTS/(subcarriers*Mod*Coding))*Ts;
	TxBAK = PHY_h+ceil(PSDU_BAK/(subcarriers*Mod*Coding))*Ts;

	TxD = TxPSDU+s*(SIFS+TxBAK)+DIFS+SLOT;

    end
end
    
end