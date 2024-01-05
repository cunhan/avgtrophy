with open("bulianglin.txt", 'r') as bll:
    lines = bll.readlines()
    lines.sort()
    nodes = {}
    for ll in lines:
        #clash 不支持 vless,hysteria; del jp
        if ll.startswith("vless") or ll.startswith("hysteria") or '%E6%97%A5%E6%9C%AC' in ll:
            continue
        x = ll.split('#')
        x.append("")
        nodes[x[0]] = x[1]
    dedup = []
    for key in nodes:
        if nodes[key] == "":
            dedup.append(key)
        else:
            dedup.append('#'.join([key, nodes[key]])) 
    
with open("bulianglin_dedup.txt", 'w') as bll:
    bll.writelines(dedup)