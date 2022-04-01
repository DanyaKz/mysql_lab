-- 2.1 
select * from employees 
where salary > (select avg(salary) from employees where job_id like '%it%' ); 
-- 2.2 
select full_name, length(replace(full_name, ' ','')) 'Length' 
from employees 
where length(replace(full_name, ' ','')) =  (select max(length(replace(full_name, ' ',''))) from employees) ;
-- 2.3
select distinct employee_id, full_name, min(salary) , department_id 
from employees 
group by department_id;
-- 2.4
select * from departments d1
where exists (
	select * 
    from employees e1
    where d1.manager_id = e1.employee_id and 
    e1.hire_dat = (select min(hire_dat) from employees)
);
-- 2.5
select * from departments 
where department_id = (
	select department_id 
    from employees 
    group by department_id
    having count(department_id) = (
		select max(my_count) from (
			select count(department_id) as my_count from employees group by department_id ) sub
    )
);
-- 2.6
select * from departments 
where department_id in (
	select department_id
    from employees 
    group by department_id
    having min(salary) > (
		 select distinct min(salary) from employees where department_id = 50)
);
-- 2.7
select distinct dep_id , max(avg_sal) 'Max'
from ( select department_id as dep_id , avg(salary) as avg_sal from employees group by department_id ) sub ;
-- 2.8
select full_name, email, phone_number, job_id, salary, department_name  from departments
join employees on departments.department_id = employees.department_id;
-- 2.9
select * from departments d
where not exists (
	select * 
    from employees e
    where d.department_id = e.department_id
    );
-- 2.10
select * from employees e 
join job_grades j on e.salary between j.lowest_sal and j.highest_sal ;
-- 2.11 
select d.department_name 'Department' , my_count 'Count' , e.full_name 'Manager'  from departments d 
join employees e on d.manager_id = e.employee_id 
join (select department_id , count(e1.department_id) as my_count from employees e1 group by e1.department_id) sub on sub.department_id = d.department_id;
-- 2.12
select e.full_name 'Full name' , e.job_id 'Job', e.hire_dat 'Hire date', d.department_name 'Department' from departments d 
join employees e 
	on e.hire_dat between '1995-1-1' and '2021-02-11' and d.department_id = e.department_id 
join job_grades j
	on e.salary between j.lowest_sal and j.highest_sal and j.gra in ('A','B','C') ;
-- 2.13
select e.full_name 'Full name', l.loc_name 'City' from employees e 
join locations l on e.loc_id = l.loc_id ;
-- 2.14 
select e.full_name 'Full name', l.loc_name 'City' , e.salary/10  'Montly pension contribution',
e.salary/10 * 12 'Annual pension contribution' , (e.salary - e.salary/10)/10 'Montly medicines contribution',
(e.salary - e.salary/10)/10 * 12 'Annual medicines contribution'
from employees e 
join locations l on e.loc_id = l.loc_id ;
-- 2.15
select  l.loc_name 'City', avg(salary) 'Avg salary'  from employees e 
join locations l on e.loc_id = l.loc_id 
group by l.loc_name
order by avg(salary) desc
limit 3;
-- 2.16
select e1.employee_id, e1.full_name, e1.phone_number, e1.salary 'Salary of employee' , e1.department_id, sub.full_name 'Manager is a loser', sub.salary 'Salary of manager'  from employees e1, (
select e.department_id, e.full_name, e.salary 
from employees e
join departments d 
on e.employee_id = d.manager_id) sub
where e1.salary > sub.salary and e1.department_id = sub.department_id
group by e1.full_name
;
-- 2.17
select * from employees e , (
	select d1.manager_id , d1.department_id from departments d1
	join employees e1 on d1.department_id = e1.department_id
	and e1.employee_id in (142,144) group by manager_id ) sub
where sub.department_id = e.department_id and employee_id != sub.manager_id;
 -- 2.18 
select d.department_name , avg(salary) 'Avg salary'  from employees e 
join departments d on d.department_id = e.department_id 
group by d.department_name
order by avg(salary) 
limit 2,1;
-- 2.19
select * from employees e
join locations l on e.loc_id = l.loc_id and l.loc_name = 'Saitama';
-- 2.20
select *  from employees e
where full_name not in (
	select e1.full_name from employees e1
    join departments d1 on e1.employee_id = d1.manager_id
);
-- 2.21
select * from employees e
join locations l on e.loc_id = l.loc_id and l.loc_name = 'Saitama';
-- 2.22 
select * from employees e 
join locations l on e.loc_id = l.loc_id 
and e.employee_id = 107;  
-- 2.23 
-- I'm sure a manager_id couldn't have the manager_id because table departments doesnt exist that. 
-- So I thought a little then I found my own solution : 
-- The manager is a subordinate if he's the only one in the department. In fact, he is his own subordinate and his own manager (*-*)
select * from employees
group by department_id
having count(department_id) = 1;
-- 2.24
select sub1.country_name 'Country Name' , avg(sub1.salary) 'Average Salary'
from (select full_name,  country_name, salary 
	from employees e
	join locations l 
		on e.loc_id = l.loc_id
	join countries c 
		on l.country_id = c.country_id 
	where l.country_id = 'KOR'
	order by full_name
	limit 2) sub1
union all 
select sub2.country_name , avg(sub2.salary) 
from (select full_name, country_name, salary 
	from employees e
	join locations l 
		on e.loc_id = l.loc_id
	join countries c 
		on l.country_id = c.country_id 
	where l.country_id = 'JPN'
	order by full_name
	limit 2) sub2;
-- 2.25
select c.country_name ,l.loc_name, e.department_id, count(e.employee_id) 'Count of employees'
from employees e
join locations l 
	on e.loc_id = l.loc_id
join countries c 
	on l.country_id = c.country_id
group by department_id
having count(employee_id) >= 2;
-- 2.26
-- Write a query to display max salary for each country 
select sub1.country_name 'Country Name' , max(sub1.salary) 'Max Salary'
from (select e.salary , l.loc_name , c.country_name
	from locations l
	join employees e
		on l.loc_id = e.loc_id
	join countries c 
		on l.country_id = c.country_id 
	where l.country_id = 'KOR') sub1
union all
select sub2.country_name , max(sub2.salary) 
from (select e.salary , l.loc_name , c.country_name
	from locations l
	join employees e
		on l.loc_id = e.loc_id
	join countries c 
		on l.country_id = c.country_id 
	where l.country_id = 'JPN') sub2;