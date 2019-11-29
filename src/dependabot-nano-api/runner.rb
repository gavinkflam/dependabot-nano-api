require "dependabot/file_fetchers"
require "dependabot/file_parsers"
require "dependabot/update_checkers"
require "dependabot/file_updaters"
require "dependabot/pull_request_creator"
require "dependabot/omnibus"
require "gitlab"

module DependabotNanoApi
  module Runner
    def self.run!(config, repo_name, token, package_manager)
      source = Dependabot::Source.new(
        provider: "gitlab",
        hostname: config[:gitlab_host],
        api_endpoint: "https://#{config[:gitlab_host]}/api/v4",
        repo: repo_name,
        directory: '/',
        branch: nil,
      )
      credentials = {
        "type" => "git_source",
        "host" => config[:gitlab_host],
        "username" => "x-access-token",
        "password" => token
      }

      ##############################
      # Fetch the dependency files #
      ##############################
      puts "Fetching #{package_manager} dependency files for #{repo_name}"
      fetcher = Dependabot::FileFetchers.for_package_manager(package_manager).new(
        source: source,
        credentials: credentials
      )

      files = fetcher.files
      commit = fetcher.commit

      ##############################
      # Parse the dependency files #
      ##############################
      puts "Parsing dependencies information"
      parser = Dependabot::FileParsers.for_package_manager(package_manager).new(
        dependency_files: files,
        source: source,
        credentials: credentials,
      )

      dependencies = parser.parse

      dependencies.select(&:top_level?).each do |dep|
        #########################################
        # Get update details for the dependency #
        #########################################
        checker = Dependabot::UpdateCheckers.for_package_manager(package_manager).new(
          dependency: dep,
          dependency_files: files,
          credentials: credentials,
        )

        next if checker.up_to_date?

        requirements_to_unlock =
          if !checker.requirements_unlocked_or_can_be?
            if checker.can_update?(requirements_to_unlock: :none) then :none
            else :update_not_possible
            end
          elsif checker.can_update?(requirements_to_unlock: :own) then :own
          elsif checker.can_update?(requirements_to_unlock: :all) then :all
          else :update_not_possible
          end

        next if requirements_to_unlock == :update_not_possible

        updated_deps = checker.updated_dependencies(
          requirements_to_unlock: requirements_to_unlock
        )

        #####################################
        # Generate updated dependency files #
        #####################################
        print "  - Updating #{dep.name} (from #{dep.version})…"
        updater = Dependabot::FileUpdaters.for_package_manager(package_manager).new(
          dependencies: updated_deps,
          dependency_files: files,
          credentials: credentials,
        )

        updated_files = updater.updated_dependency_files

        ########################################
        # Create a pull request for the update #
        ########################################
        pr_creator = Dependabot::PullRequestCreator.new(
          source: source,
          base_commit: commit,
          dependencies: updated_deps,
          files: updated_files,
          credentials: credentials,
          assignees: [(ENV["PULL_REQUESTS_ASSIGNEE"] || ENV["GITLAB_ASSIGNEE_ID"])&.to_i],
          label_language: true,
        )

        pr_creator.create
        puts "submitted"
      end
    end
  end
end
