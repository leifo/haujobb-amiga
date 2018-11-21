	incdir  wos:
        ifnd    ISREADY
                include Wos_v1.63.s
        else    
                include sub/wos_incall.i
                
                ifd     LIB
                        include wos:sub/wos_header-lib.s
                else
                        include wos:sub/wos_header-exe.s
                endc
        endc
