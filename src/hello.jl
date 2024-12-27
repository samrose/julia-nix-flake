println("Hello from Julia!")

function main()
    # Your Julia code here
    println("Current time: ", now())
    println("Arguments: ", join(ARGS, " "))
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end