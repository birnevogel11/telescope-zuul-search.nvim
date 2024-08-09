return require("telescope").register_extension({
  setup = function(ext_config, config)
    local zs = require("telescope-zuul-search.zs_cmd")

    ext_config = ext_config or {}

    if ext_config.zs_path ~= nil then
      zs.program = ext_config.zs_path
    end
  end,
  exports = {
    jobs = require("telescope-zuul-search.zs").jobs,
    roles = require("telescope-zuul-search.zs").roles,
    job_hierarhcy = require("telescope-zuul-search.zs").job_hierarhcy,
    job_hierarhcy_with_job_name = require("telescope-zuul-search.zs").job_hierarhcy_with_job_name,
    job_vars = require("telescope-zuul-search.zs").job_vars,
    job_vars_with_job_name = require("telescope-zuul-search.zs").job_vars_with_job_name,
    job_playbooks = require("telescope-zuul-search.zs").job_playbooks,
    job_playbooks_with_job_name = require("telescope-zuul-search.zs").job_playbooks_with_job_name,
    project_templates = require("telescope-zuul-search.zs").project_templates,
    workdir_vars = require("telescope-zuul-search.zs").workdir_vars,
  },
})
