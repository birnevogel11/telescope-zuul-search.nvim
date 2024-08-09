local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")

local zs = require("telescope-zuul-search.zs_cmd")

local make_entry_maker_func = function(displayer_items, make_display_func, opts)
  local displayer = entry_display.create({
    separator = " ",
    items = displayer_items,
  })

  return function(entry)
    entry.display = make_display_func(displayer)
    return make_entry.set_default_entry_mt(entry, opts)
  end
end

local pickers_find = function(opts, prompt_title, results, entry_maker, is_preview_file, attach_mappings)
  local previewer = nil
  if is_preview_file then
    previewer = conf.file_previewer
  else
    previewer = conf.grep_previewer
  end

  pickers
    .new(opts, {
      prompt_title = prompt_title,
      finder = finders.new_table({
        results = results,
        entry_maker = entry_maker,
      }),
      sorter = conf.generic_sorter(opts),
      previewer = previewer(opts),
      attach_mappings = attach_mappings,
    })
    :find()
end

local zuul_roles = function(opts)
  opts = opts or {}
  if opts.zuul_local == true then
    subcommand = "roles --local"
  end
  local cmd_results = zs.roles(subcommand or "roles")
  local results = cmd_results.results
  local widths = cmd_results.widths

  if #results == 0 then
    return
  end

  local displayer_items = {
    { width = widths.value },
    { width = widths.path },
  }

  local make_display_func = function(displayer)
    return function(entry)
      return displayer({
        { entry.value },
        { entry.path },
      })
    end
  end
  local entry_maker = make_entry_maker_func(displayer_items, make_display_func, opts)

  pickers_find(opts, "Zuul roles", results, entry_maker, false, nil)
end

local zuul_jobs = function(opts, subcommand, attach_mappings)
  opts = opts or {}
  if opts.zuul_local == true then
    subcommand = "jobs --local"
  end
  local cmd_results = zs.jobs(subcommand)
  local results = cmd_results.results
  local widths = cmd_results.widths

  if #results == 0 then
    return
  end

  local make_display_func = function(displayer)
    return function(entry)
      return displayer({
        { entry.value },
        { entry.path },
      })
    end
  end
  local displayer_items = {
    { width = widths.value },
    { width = widths.path },
  }
  local entry_maker = make_entry_maker_func(displayer_items, make_display_func, opts)

  pickers_find(opts, "Zuul job", results, entry_maker, false, attach_mappings)
end

local zuul_project_templates = function(opts)
  opts = opts or {}
  if opts.zuul_local == true then
    subcommand = "project-templates --local"
  end
  local cmd_results = zs.project_templates(subcommand or "project-templates")
  local results = cmd_results.results
  local widths = cmd_results.widths

  if #results == 0 then
    return
  end

  local make_display_func = function(displayer)
    return function(entry)
      return displayer({
        { entry.value },
        { entry.path },
      })
    end
  end
  local displayer_items = {
    { width = widths.value },
    { width = widths.path },
  }
  local entry_maker = make_entry_maker_func(displayer_items, make_display_func, opts)

  pickers_find(opts, "Zuul projecttemplates", results, entry_maker, false, nil)
end

local call_with_zuul_job = function(opts, callback)
  local attach_mappings = function(prompt_bufnr, map)
    actions.select_default:replace(function()
      actions.close(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      opts.job_name = selection.value
      callback(opts)
    end)
    return true
  end

  zuul_jobs(opts, nil, attach_mappings)
end

local make_zuul_job_attribute_search_func = function(internal_func)
  return function(opts)
    opts = opts or {}

    if opts.job_name ~= nil then
      internal_func(opts)
    else
      call_with_zuul_job(opts, internal_func)
    end
  end
end

local zuul_job_hierarhcy_with_job_name = function(opts)
  zuul_jobs(opts, "job-hierarchy " .. opts.job_name)
end

local zuul_job_vars_with_job_name = function(opts)
  opts = opts or {}
  local job_name = opts.job_name
  local cmd_results = zs.job_vars(job_name)
  local results = cmd_results.results
  local widths = cmd_results.widths

  if #results == 0 then
    return
  end

  local displayer_items = {
    { width = widths.value },
    { width = widths.zuul_job_name },
    { width = widths.assigned_value },
  }
  local make_display_func = function(displayer)
    return function(entry)
      return displayer({
        { entry.value },
        { entry.zuul_job_name },
        { entry.assigned_value },
      })
    end
  end
  local entry_maker = make_entry_maker_func(displayer_items, make_display_func, opts)

  pickers_find(opts, "Zuul job vars", results, entry_maker, false, nil)
end

local zuul_job_playbooks_with_job_name = function(opts)
  local job_name = opts.job_name
  local cmd_results = zs.job_playbooks(job_name)
  local results = cmd_results.results
  local widths = cmd_results.widths

  if #results == 0 then
    return
  end

  local displayer_items = {
    { width = widths.value },
    { width = widths.playbook_type },
    { width = widths.zuul_job_name },
  }

  local make_display_func = function(displayer)
    return function(entry)
      return displayer({
        { entry.value },
        { entry.playbook_type },
        { entry.zuul_job_name },
      })
    end
  end
  local entry_maker = make_entry_maker_func(displayer_items, make_display_func)

  pickers_find(opts, "Zuul job playbooks", results, entry_maker, true, nil)
end

local zuul_workdir_vars = function(opts)
  opts = opts or {}
  local cmd_results = zs.workdir_vars()
  local results = cmd_results.results
  local widths = cmd_results.widths

  if #results == 0 then
    return
  end

  local displayer_items = {
    { width = widths.value },
    { width = widths.zuul_job_name },
    { width = widths.assigned_value },
  }
  local make_display_func = function(displayer)
    return function(entry)
      return displayer({
        { entry.value },
        { entry.zuul_job_name },
        { entry.assigned_value },
      })
    end
  end
  local entry_maker = make_entry_maker_func(displayer_items, make_display_func, opts)

  pickers_find(opts, "Zuul workdir vars", results, entry_maker, false, nil)
end

local zuul_job_playbooks = make_zuul_job_attribute_search_func(zuul_job_playbooks_with_job_name)
local zuul_job_vars = make_zuul_job_attribute_search_func(zuul_job_vars_with_job_name)
local zuul_job_hierarhcy = make_zuul_job_attribute_search_func(zuul_job_hierarhcy_with_job_name)

return {
  jobs = zuul_jobs,
  roles = zuul_roles,
  workdir_vars = zuul_workdir_vars,
  job_hierarhcy = zuul_job_hierarhcy,
  job_hierarhcy_with_job_name = zuul_job_hierarhcy_with_job_name,
  job_vars = zuul_job_vars,
  job_vars_with_job_name = zuul_job_vars_with_job_name,
  job_playbooks = zuul_job_playbooks,
  job_playbooks_with_job_name = zuul_job_playbooks_with_job_name,
  project_templates = zuul_project_templates,
}
