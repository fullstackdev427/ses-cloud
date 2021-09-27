<div id="edit_search_skill_condition_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h4 class="modal-title">
					<span class="glyphicon glyphicon-plus-sign">&nbsp;<span id="edit_branch_modal_title">スキル条件追加</span></span>
					<button type="button" class="btn btn-default pull-right" data-dismiss="modal">閉じる</button>
				</h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
                <form>
                    <div class="container-fluid">
                        <div class="input-group">
                            <span>
                                <input type="checkbox" id="m_skill_sort"/>
                                <label for="m_skill_sort" class="text-danger">50音順</label>
                            </span>
                        </div>
                        <div id="skill_list">
                            {% if data['skill.enumSkills'] %}
                                {% for itemC in data['skill.enumSkillCategories'] %}
                                    <div id="search_skill_categories_header_{{ loop.index }}" style="border-bottom: 1px solid #e5e5e5; margin-bottom: 10px;margin-top: 10px"><label>{{ itemC }}</label></div>
                                    <table class="">
                                     {% for item in data['skill.enumSkills'] %}
                                         {% if itemC == item.category_name %}
                                         <tr>
                                             <td>
                                                 <input type="checkbox" name="search_skill[]" id="search_skill_label_{{ item.id }}" class="search-chk" onchange="viewSelectedSkill();" value="{{ item.id }}">
                                                 <label id="skill_{{ item.id }}" for="search_skill_label_{{ item.id }}" style="font-weight: normal; margin: 0px">{{ item.name }}</label>
                                             </td>
                                             <td>
                                                 <select id="search_skill_level_{{ item.id }}" name="search_skill_level[]" value="" class="" onchange="viewSelectedSkill();">
                                                    <option value="0">----</option>
                                                    {% if (data['matching.type'] == "matching.engineer") %}
                                                        {% for itemL in data['skill.enumSkillLevels'] %}
                                                            {% if (itemL.name != "未経験") %}
                                                                <option value="{{itemL.level}}">{{itemL.name}}</option>
                                                            {% endif %}
                                                        {% endfor %}
                                                    {% else %}
                                                        {% for itemL in data['skill.enumSkillLevels'] %}
                                                            <option value="{{itemL.level}}">{{itemL.name}}</option>
                                                        {% endfor %}
                                                    {% endif %}
                                                </select>
                                             </td>
                                         </tr>
                                        {% endif %}
                                     {% endfor %}
                                    </table>
                                {% endfor %}
                            {% endif %}
                        </div>
                    </div>
                </form>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
    <div style="width:150px;position: fixed;top:20%;right: 30%;z-index: 1100;">
        <ul class="list-group">
            <li class="list-group-item" style="">スキルカテゴリ</li>
        {% for itemC in data['skill.enumSkillCategories'] %}
            <li class="list-group-item" style="color: #428bca;cursor: pointer;height: auto;" onclick="location.href='#search_skill_categories_header_{{ loop.index }}'">{{ itemC }}</li>
        {% endfor %}
        </ul>
    </div>
</div><!-- div.modal -->