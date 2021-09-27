ALTER TABLE mt_skills ADD sort_number mediumint(10) unsigned;
update mt_skills set sort_number = (1000 * category_id + id);


