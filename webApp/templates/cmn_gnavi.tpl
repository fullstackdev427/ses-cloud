<div class="row">
    <nav id="nav" role="navigation">
        <a href="#nav" title="Show navigation">Show navigation</a>
        <a href="#" title="Hide navigation">Hide navigation</a>
        <ul class="clearfix">
            <li class="gnavi-btn first{% if current == 'home.enum' %} current{% endif %} pseudo-link-cursor left_line">
                <a onclick="c4s.hdlClickGnaviBtn('home.enum');">ホーム</a>
            </li>
            <li class="gnavi-btn{% if current == 'matching.project' or current == 'matching.engineer' %} current{% endif %} pseudo-link-cursor left_line dropdown">
                <a class="dropdown-toggle" data-toggle="dropdown" style="pointer-events: none;">マッチング</a>
                <ul class="dropdown-menu" role="menu" style="margin-top: 0px">
                    <li style="background: #225fb1;border-bottom: 1px solid rgb(30, 84, 157);"><a href="#" onclick="c4s.hdlClickGnaviBtn('matching.project');">案件マッチング</a></li>
                    <li style="background: #225fb1;"><a href="#" onclick="c4s.hdlClickGnaviBtn('matching.engineer');">要員マッチング</a></li>
                </ul>
            </li>
            <li class="gnavi-btn{% if current == 'client.clientTop' or current == 'client.workerTop' %} current{% endif %} pseudo-link-cursor left_line dropdown">
                <a class="dropdown-toggle" data-toggle="dropdown" style="pointer-events: none;">取引先</a>
                <ul class="dropdown-menu" role="menu" style="margin-top: 0px">
                    <li style="background: #225fb1;border-bottom: 1px solid rgb(30, 84, 157);"><a href="#" onclick="c4s.hdlClickGnaviBtn('client.clientTop');">取引先</a></li>
                    <li style="background: #225fb1;border-bottom: 1px solid rgb(30, 84, 157);"><a href="#" onclick="c4s.hdlClickGnaviBtn('client.workerTop');">取引先担当者</a></li>
                </ul>
            </li>
            <li class="gnavi-btn{% if current == 'project.top' or current == 'engineer.top' %} current{% endif %} pseudo-link-cursor left_line dropdown">
                <a class="dropdown-toggle" data-toggle="dropdown" style="pointer-events: none;">案件 / 要員</a>
                <ul class="dropdown-menu" role="menu" style="margin-top: 0px">
                    <li style="background: #225fb1;border-bottom: 1px solid rgb(30, 84, 157);"><a href="#" onclick="c4s.hdlClickGnaviBtn('project.top', {flg_shared: true});">案件</a></li>
                    <li style="background: #225fb1;"><a href="#" onclick="c4s.hdlClickGnaviBtn('engineer.top', {flg_assignable: true});">要員</a></li>
                </ul>
            </li>
            <li class="gnavi-btn{% if current == 'operation.top' or current == 'estimate.top' or current == 'order.top' or current == 'purchase.top' or current == 'invoice.top' %} current{% endif %} pseudo-link-cursor last left_line dropdown">
                <a class="dropdown-toggle" data-toggle="dropdown" style="pointer-events: none;">契約管理</a>
                <ul class="dropdown-menu" role="menu" style="margin-top: 0px">
                    <li style="background: #225fb1;border-bottom: 1px solid rgb(30, 84, 157);"><a href="#" onclick="c4s.hdlClickGnaviBtn('operation.top');">稼働</a></li>
                    <li style="background: #225fb1;border-bottom: 1px solid rgb(30, 84, 157);"><a href="#" onclick="c4s.hdlClickGnaviBtn('estimate.top');">見積書</a></li>
                    {#<li style="background: #225fb1;border-bottom: 1px solid rgb(30, 84, 157);"><a href="#" onclick="c4s.hdlClickGnaviBtn('order.top');">請求先注文書</a></li>#}
                    <li style="background: #225fb1;border-bottom: 1px solid rgb(30, 84, 157);"><a href="#" onclick="c4s.hdlClickGnaviBtn('purchase.top');">注文書</a></li>
                    <li style="background: #225fb1;"><a href="#" onclick="c4s.hdlClickGnaviBtn('invoice.top');">請求書</a></li>
                </ul>
            </li>
        </ul>
    </nav>
</div>
