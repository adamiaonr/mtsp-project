% sandbox script to test the whole thing...

%% Pre-Round (Entities, topology, etc.)

% overall parameters
content_n = 10;
cs_size = 5;
round_n = 500;

% Let's hard-wire a cascade topology, 3 levels (i.e. NDN routers), 1 client
% 1 server.
rtr_n = 3;

for i = 1:rtr_n

    rtr(i) = router(i, 2, content_n, cs_size, 'LRU');
    
end

lambda = [0.9 0.7 0.5 0.4 0.3 0.2 0.1 0.1 0.1 0.1];
clnt = client(content_n, lambda');
srvr = server(content_n);

%% Rounds

for r = 1:round_n

    r;
    
    % 1) client generates Interests
    clnt.requestContent;
    
    % 1.1) NDN router 1 fills input of downstream interface (1)
    rtr(1).ifaces.putInPort(clnt.iface.getOutPort(1), 1);
    rtr(1).ifaces.putInPort(rtr(2).ifaces.getOutPort(1), 2);
    
    % 2) routers fill inputs from all interfaces
    for i = 2:(rtr_n - 1)
        
        rtr(i).ifaces.putInPort(rtr(i - 1).ifaces.getOutPort(2), 1);
        rtr(i).ifaces.putInPort(rtr(i + 1).ifaces.getOutPort(1), 2);
        
    end
    
    rtr(rtr_n).ifaces.putInPort(rtr(rtr_n - 1).ifaces.getOutPort(2), 1);
    rtr(rtr_n).ifaces.putInPort(srvr.iface.getOutPort(1), 2);

    
    % 3) server fetches inputs
    srvr.iface.putInPort(rtr(rtr_n).ifaces.getOutPort(2), 1);
    
    % 4) we can clear all the outputs
    clnt.iface.clearOutPorts;
    srvr.iface.clearOutPorts;
    
    for i = 1:rtr_n
        
        rtr(i).ifaces.clearOutPorts;
        
    end
    
    % 5) it's processing time for the routers, first the Interests, then
    % the Data
    for i = 1:rtr_n
        
        rtr(i).forwardInterests;
        rtr(i).forwardData;
        
        rtr(i).getOut;
        
    end
    
    % 6) it's the server's time
    srvr.answer;
    
    % 7) we can clear all inputs
    clnt.iface.clearInPorts;
    srvr.iface.clearInPorts;
    
    for i = 1:rtr_n
        
        rtr(i).ifaces.clearInPorts;
        
    end
end

% %% Round 1 (Initial Interests)
% 
% % 1) create a simple cascade topology, only 1 NDN router, 5 types of
% % content objects, 2 interfaces, CS with 3 slots and LRU replacement
% % policy
% rtr = router(1, 2, 5, 3, 'LRU');
% 
% % 2) create an input on the downstream side (iface 1), with Interest 
% % signals for objects 1 and 3.
% inputs = [1 0 1 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0]';
% 
% % 3) insert the signals in the router's downstream interface (1), input
% % port
% rtr.putIn(inputs);
% 
% % 4) forward the Interests towards the upstream interface(s), according to
% % the FIB. show the contents of the input, output, PIT, FIB and CS after
% % the operation.
% rtr.forwardInterests;
% 
% % 4.1) Inputs
% rtr.getIn
% 
% % 4.1.1) Erase the inputs
% rtr.ifaces.clearInPorts;
% 
% % 4.2) Outputs
% rtr.getOut
% 
% % 4.2.1) Erase the outputs (not important for now, as we don't have any
% % elements upstream)
% rtr.ifaces.clearOutPorts;
% 
% % 4.3) PIT
% rtr.PIT.showPIT
% 
% % 4.4) FIB
% rtr.FIB
% 
% % 4.5) CS
% rtr.CS.CACHE
% 
% % 5) Interests are forwarded, let's simulate some incoming Data for all 
% % content objects. Hopefully, if everything goes fine, objects 2, 4 and 5
% % are discarded, while objects 1 and 3 are correctly forwarded
% % downstream. These Data signals are incoming on interface 2.
% inputs = [0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 1 1 1 1 1]';
% 
% % 6) insert the inputs on the appropriate interfaces
% rtr.putIn(inputs);
%  
% % 7) forward the Data towards the downstream interface(s), according to
% % the PIT. show the contents of the input, output, PIT, FIB and CS after
% % the operation.
% rtr.forwardData;
% 
% % 7.1) Inputs
% rtr.getIn
% 
% % 7.1.1) Erase the inputs
% rtr.ifaces.clearInPorts;
% 
% % 7.2) Outputs
% rtr.getOut
% 
% % 7.2.1) Erase the outputs (not important for now, as we don't have any
% % elements upstream)
% rtr.ifaces.clearOutPorts;
% 
% % 7.3) PIT
% rtr.PIT.showPIT
% 
% % 7.4) FIB
% rtr.FIB
% 
% % 7.5) CS
% rtr.CS.CACHE
% 
% %% Round 2 (Overload the CS)
% 
% % 8) create an input on the downstream side (iface 1), with Interest 
% % signals for objects 2, 4 and 5.
% inputs = [0 1 0 1 1 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0]';
% 
% % 9) insert the signals in the router's downstream interface (1), input
% % port
% rtr.putIn(inputs);
% 
% % 10) forward the Interests towards the upstream interface(s), according to
% % the FIB. show the contents of the input, output, PIT, FIB and CS after
% % the operation.
% rtr.forwardInterests;
% 
% % 10.1) Inputs
% rtr.getIn
% 
% % 10.1.1) Erase the inputs
% rtr.ifaces.clearInPorts;
% 
% % 10.2) Outputs
% rtr.getOut
% 
% % 10.2.1) Erase the outputs (not important for now, as we don't have any
% % elements upstream)
% rtr.ifaces.clearOutPorts;
% 
% % 10.3) PIT
% rtr.PIT.showPIT
% 
% % 10.4) FIB
% rtr.FIB
% 
% % 10.5) CS
% rtr.CS.CACHE
% 
% % 11) Interests are forwarded, let's simulate some incoming Data for all 
% % content objects. Hopefully, if everything goes fine, objects 1 and 3 
% % are discarded, while objects 2, 4 and 5 are correctly forwarded
% % downstream. These Data signals are incoming on interface 2.
% inputs = [0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 1 1 1 1 1]';
% 
% % 12) insert the inputs on the appropriate interfaces
% rtr.putIn(inputs);
%  
% % 13) forward the Data towards the downstream interface(s), according to
% % the PIT. show the contents of the input, output, PIT, FIB and CS after
% % the operation.
% rtr.forwardData;
% 
% % 13.1) Inputs
% rtr.getIn
% 
% % 13.1.1) Erase the inputs
% rtr.ifaces.clearInPorts;
% 
% % 13.2) Outputs
% rtr.getOut
% 
% % 13.2.1) Erase the outputs (not important for now, as we don't have any
% % elements upstream)
% rtr.ifaces.clearOutPorts;
% 
% % 13.3) PIT
% rtr.PIT.showPIT
% 
% % 13.4) FIB
% rtr.FIB
% 
% % 13.5) CS
% rtr.CS.CACHE
